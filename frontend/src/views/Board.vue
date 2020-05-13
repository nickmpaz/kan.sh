<template>
<v-container class="d-flex flex-column fill-height">
    <!-- top bar -->
    <div class="flex-shrink-1 align-self-stretch">
        <v-row align="center" justify="center" class="my-3">
            <v-col cols="auto">
                <v-tooltip :disabled="!tooltips" bottom>
                    <template v-slot:activator="{ on }">
                        <v-btn fab @click.stop="$router.push('/')" v-on="on">
                            <v-icon>mdi-keyboard-backspace</v-icon>
                        </v-btn>
                    </template>
                    <span>Back</span>
                </v-tooltip>
            </v-col>

            <v-col class="flex-grow-1">
                <v-text-field hide-details outlined rounded v-model="board_contents.name" class="title" @keydown.enter="$event.target.blur()" @blur="updateBoardContents()"></v-text-field>
            </v-col>

            <v-col cols="auto">
                <v-tooltip :disabled="!tooltips" bottom>
                    <template v-slot:activator="{ on }">
                        <v-btn color="error" fab @click.stop="deleteBoard" v-on="on">
                            <v-icon>mdi-delete</v-icon>
                        </v-btn>
                    </template>
                    <span>Delete Board</span>
                </v-tooltip>

            </v-col>
            <v-col cols="auto">
                <v-tooltip :disabled="!tooltips" bottom>
                    <template v-slot:activator="{ on }">
                        <v-btn color="info" fab @click.stop="exportBoard" v-on="on">
                            <v-icon>mdi-export</v-icon>
                        </v-btn>
                    </template>
                    <span>Export Board</span>
                </v-tooltip>

            </v-col>
            <v-col cols="auto">
                <v-tooltip :disabled="!tooltips" bottom>
                    <template v-slot:activator="{ on }">
                        <v-btn color="success" fab @click.stop="shareDialog = true" v-on="on">
                            <v-icon>mdi-share</v-icon>
                        </v-btn>
                    </template>
                    <span>Share Board</span>
                </v-tooltip>

            </v-col>
            <v-col cols="auto">
                <v-tooltip :disabled="!tooltips" bottom>
                    <template v-slot:activator="{ on }">
                        <v-btn color="accent" fab @click.stop="createColumn" v-on="on">
                            <v-icon>mdi-plus</v-icon>
                        </v-btn>
                    </template>
                    <span>Create Column</span>
                </v-tooltip>

            </v-col>
        </v-row>
    </div>
    <!-- board -->
    <div class="flex-grow-1 align-self-stretch">
        <draggable v-model="board_contents.columns" v-bind="columnDragOptions" @end="updateBoardContents" class="fill-height d-flex">
            <v-col v-for="(column, colIndex) in board_contents.columns" :key="colIndex" cols="colSpan" align="start" class="fill-height draggable-column">

                <v-card class="fill-height d-flex flex-column">
                    <div class="flex-shrink-1">
                        <v-toolbar color="primary" dark flat>
                            <v-icon class="handle" large>mdi-drag</v-icon>
                            <v-text-field hide-details rounded color="white" v-model="board_contents.columns[colIndex].name" placeholder="Untitled" class="title" @keydown.enter="$event.target.blur()" @blur="updateBoardContents"></v-text-field>
                            <v-tooltip :disabled="!tooltips" bottom>
                                <template v-slot:activator="{ on }">
                                    <v-btn @click.stop="deleteColumn(colIndex)" icon v-on="on">
                                        <v-icon>mdi-delete</v-icon>
                                    </v-btn>
                                </template>
                                <span>Delete Column</span>
                            </v-tooltip>
                            <v-tooltip :disabled="!tooltips" bottom>
                                <template v-slot:activator="{ on }">
                                    <v-btn @click.stop="createCard(colIndex)" icon v-on="on">
                                        <v-icon>mdi-plus</v-icon>
                                    </v-btn>
                                </template>
                                <span>Create Card</span>
                            </v-tooltip>

                        </v-toolbar>
                    </div>
                    <div class="flex-grow-1">

                        <draggable v-model="board_contents.columns[colIndex].cards" v-bind="cardDragOptions" @end="updateBoardContents" class="fill-height d-flex flex-column">
                            <v-card v-for="(card, cardIndex) in column.cards" :key="card.id" class="mx-3 mt-3 draggable-card cursor-pointer" role="button" @click.native="editCard(colIndex, cardIndex)" color="secondary">
                                <v-card-text class="title">
                                    {{ card.title }}
                                </v-card-text>
                            </v-card>
                        </draggable>
                    </div>

                </v-card>

            </v-col>
        </draggable>
    </div>
    <!-- dialogs -->
    <loading-dialog :active="loadingDialog" message="Loading" />
    <loading-dialog :active="deleteLoadingDialog" message="Deleting"/>
    <create-card-dialog :active="createCardDialog" @cancelDialog="cancelDialog" @saveCreateCard="saveCreateCard" />
    <edit-card-dialog :active="editCardDialog" :title="editTitle" :description="editDescription" @cancelDialog="cancelDialog" @saveEditCard="saveEditCard" @deleteEditCard="deleteEditCard" />
    <share-dialog :active="shareDialog" @cancelDialog="cancelDialog" @shareBoard="shareBoard" />

</v-container>
</template>

<script>
import draggable from 'vuedraggable'
import LoadingDialog from '../components/LoadingDialog'
import CreateCardDialog from '../components/CreateCardDialog'
import EditCardDialog from '../components/EditCardDialog'
import ShareDialog from '../components/ShareDialog'

import {
    Auth
} from 'aws-amplify'

export default {
    props: ['websocket', 'configureBackend', 'connectToBackend', 'tooltips'],
    computed: {
        cardDragOptions() {
            return {
                draggable: '.draggable-card',
                group: 'cards',
                animation: 200,
                ghostClass: 'ghost',
            }
        },
        columnDragOptions() {
            return {
                draggable: '.draggable-column',
                group: 'columns',
                animation: 200,
                ghostClass: 'ghost',
                handle: '.handle'
            }
        },
        colSpan() {
            return Math.floor(12 / this.board_contents.columns.length)
        }
    },
    data() {
        return {
            board_contents: {},
            loadingDialog: true,
            deleteLoadingDialog: false,
            createCardDialog: false,
            editCardDialog: false,
            colIndex: 0,
            cardIndex: 0,
            editTitle: '',
            editDescription: '',
            shareDialog: false,
        }
    },
    async created() {
        if (sessionStorage.getItem(this.$route.params.board_id)) {
            this.loadingDialog = false
            this.board_contents = JSON.parse(sessionStorage.getItem(this.$route.params.board_id))
        }
        await this.connectToBackend()
        this.$emit('setOnmessageFunction', this.onmessage)
        this.configureBackend()
        this.getBoardContents()
    },
    methods: {
        onmessage(event) {
            var dict = JSON.parse(event.data)
            console.log(dict)
            if (dict.message === this.$getBoardContentsRoute) {
                this.loadingDialog = false
                this.board_contents = dict.data.board_contents
                sessionStorage.setItem(this.$route.params.board_id, JSON.stringify(dict.data.board_contents))
            } else if (dict.message === this.$updateBoardContentsResponse) {
                console.log('here')
                this.loadingDialog = false
                this.board_contents = dict.data.board_contents
                sessionStorage.setItem(this.$route.params.board_id, JSON.stringify(dict.data.board_contents))
            } else if (dict.message === this.$deleteBoardResponse && dict.data.board_id == this.$route.params.board_id) {
                this.$router.push('/')
            }
        },
        getBoardContents() {
            Auth.currentAuthenticatedUser().then(data => {
                var msg = {
                    message: this.$getBoardContentsRoute,
                    board_id: this.$route.params.board_id,
                    token: data.signInUserSession.accessToken.jwtToken
                }
                this.websocket.send(JSON.stringify(msg))
            });
        },
        updateBoardContents() {
            console.log('update')
            Auth.currentAuthenticatedUser().then(data => {
                var msg = {
                    message: this.$updateBoardContentsRoute,
                    board_id: this.$route.params.board_id,
                    board_contents: this.board_contents,
                    token: data.signInUserSession.accessToken.jwtToken
                }
                this.websocket.send(JSON.stringify(msg))
            });
            sessionStorage.setItem(this.$route.params.board_id, JSON.stringify(this.board_contents))

        },
        createColumn() {
            this.board_contents.columns.push({
                name: 'Untitled',
                cards: []
            })
            this.updateBoardContents()
        },
        deleteColumn(colIndex) {
            this.board_contents.columns.splice(colIndex, 1)
            this.updateBoardContents()

        },
        deleteBoard() {
            this.deleteLoadingDialog = true
            Auth.currentAuthenticatedUser().then(data => {
                var msg = {
                    message: this.$deleteBoardRoute,
                    board_id: this.$route.params.board_id,
                    token: data.signInUserSession.accessToken.jwtToken
                }
                this.websocket.send(JSON.stringify(msg))
            });
        },
        createCard(colIndex) {
            this.colIndex = colIndex
            this.createCardDialog = true
        },
        saveCreateCard(cardTitle, cardDescription) {
            this.createCardDialog = false
            this.board_contents.columns[this.colIndex].cards.push({
                description: cardDescription,
                title: cardTitle
            })
            this.updateBoardContents()

        },
        editCard(colIndex, cardIndex) {
            this.colIndex = colIndex
            this.cardIndex = cardIndex
            this.editTitle = this.board_contents.columns[colIndex].cards[cardIndex].title
            this.editDescription = this.board_contents.columns[colIndex].cards[cardIndex].description
            this.editCardDialog = true
        },
        saveEditCard(cardTitle, cardDescription) {
            this.editCardDialog = false
            this.board_contents.columns[this.colIndex].cards[this.cardIndex].title = cardTitle
            this.board_contents.columns[this.colIndex].cards[this.cardIndex].description = cardDescription
            this.updateBoardContents()
        },
        deleteEditCard() {
            this.editCardDialog = false
            this.board_contents.columns[this.colIndex].cards.splice(this.cardIndex, 1)
            this.updateBoardContents()

        },
        cancelDialog() {
            this.createCardDialog = false
            this.editCardDialog = false
            this.shareDialog = false
        },
        shareBoard(username) {
            Auth.currentAuthenticatedUser().then(data => {
                var msg = {
                    message: this.$shareBoardRoute,
                    board_id: this.$route.params.board_id,
                    shareWithUsername: username,
                    token: data.signInUserSession.accessToken.jwtToken
                }
                this.websocket.send(JSON.stringify(msg))
            });
        },
        exportBoard() {
            const data = JSON.stringify(this.board_contents)
            const blob = new Blob([data], {
                type: 'text/plain'
            })
            const e = document.createEvent('MouseEvents'),
                a = document.createElement('a');
            a.download = this.board_contents.name + ".json";
            a.href = window.URL.createObjectURL(blob);
            a.dataset.downloadurl = ['text/json', a.download, a.href].join(':');
            e.initEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(e);
        },
    },
    components: {
        draggable,
        LoadingDialog,
        CreateCardDialog,
        EditCardDialog,
        ShareDialog
    }
}
</script>

<style>
.ghost {
    visibility: hidden;
}

.cursor-pointer {
    cursor: pointer;
}

.handle {
    cursor: grab;
}
</style>
