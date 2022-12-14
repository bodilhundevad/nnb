import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { chatroomId: Number, currentUserId: Number }
  static targets = ["messages"]

  connect() {
    this.channel = createConsumer().subscriptions.create(
      { channel: "ChatroomChannel", id: this.chatroomIdValue },
      { received: data => this.#insertMessageAndScrollDown(data)}
    )
    console.log(`Subscribed to the chatroom with the id ${this.chatroomIdValue}.`)
  }

  // #insertMessageAndScrollDown(data) {
  //  this.messagesTarget.insertAdjacentHTML("beforeend", data)
  //  this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
 // }

 #insertMessageAndScrollDown(data) {
  // Logic to know if the sender is the current_user

  const currentUserIsSender = this.currentUserIdValue == data.sender_id

  // Creating the whole message from the `data.message` String
  const messageElement = this.#buildMessageElement(currentUserIsSender, data.message)

  // Inserting the `message` in the DOM
  this.messagesTarget.insertAdjacentHTML("beforeend", messageElement)
  // this.messagesTarget.scrollTo(0, this.messagesTarget.scrollHeight)
  this.messagesTarget.lastElementChild.scrollIntoView()
}

  #buildMessageElement(currentUserIsSender, message) {
    return `
      <div class="message-row d-flex ${this.#justifyClass(currentUserIsSender)}">
        <div class="${this.#userStyleClass(currentUserIsSender)}">
          ${message}
        </div>
      </div>
    `
  }

  #justifyClass(currentUserIsSender) {
    return currentUserIsSender ? "msg-end" : "msg-start"
  }

  #userStyleClass(currentUserIsSender) {
    return currentUserIsSender ? "sender-style" : "receiver-style"
  }

  resetForm(event) {
    event.target.reset()
  }

  disconnect() {
    console.log("Unsubscribed from the chatroom")
    this.channel.unsubscribe()
  }

}
