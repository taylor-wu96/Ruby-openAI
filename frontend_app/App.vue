<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-header>ChatGPT-like Chatbot</el-header>
      <el-main>
        <div class="chat-area">
          <!-- Chat messages will go here -->
          <div v-for="message in messages" :key="message.id" class="message">
            <el-card>
              <div v-if="message.sender === 'user'">
                <el-tag size="small">You</el-tag>
                <div>{{ message.text }}</div>
              </div>
              <div v-else>
                <el-tag size="small" type="success">Chatbot</el-tag>
                <div>{{ message.text }}</div>
              </div>
            </el-card>
          </div>
        </div>
      </el-main>
      <el-footer>
        <el-input
          v-model="userInput"
          placeholder="Type your message here..."
          @keyup.enter="sendMessage"
          clearable
        >
          <template #append>
            <el-button type="primary"  @click="sendMessage">
              Send
               <el-icon class="el-icon--right"><ArrowRight /></el-icon>
            </el-button>
          </template>
        </el-input>
      </el-footer>
    </el-container>
  </div>
</template>

<script>
import axios from "axios";
import { ref } from 'vue';

export default {
  setup() {
    const messages = ref([]);
    const userInput = ref('');

    const sendMessage = () => {
      if (userInput.value.trim()) {
        // messages.value.push({ id: Date.now(), text: userInput.value, sender: 'user' });
        // Here you'd typically send the message to your backend for processing
        createMessage(userInput.value,'user');
        getResponse(userInput.value);
        userInput.value = ''; // Clear input after sending
      }
    };

    //Create a message
    function createMessage(message,identity) {
      let id = 0;
      if (messages.value[messages.value.length - 1]) {
        id = messages.value[messages.value.length - 1].id + 1;
      }
      messages.value.push({
        id: Date.now(),
        text: message,
        sender: identity || "user",
      });
    }
    // Get response from the backend

    async function getResponse(message) {
      const postData = {
        message_content: message,
        system_content: "user",
      };
      const { data } = await axios.post("/openai", postData);
      console.log(data);
      createMessage(data.response, "assistant");
    }

    return { messages, userInput, sendMessage };
  },
};
</script>

<style>
/* Add your styles here */
.message {
  margin-bottom: 20px;
}
</style>

