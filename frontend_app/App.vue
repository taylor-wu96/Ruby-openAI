<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-container class="dashboard" style="height:100%">
        <el-header>ChatGPT-like Chatbot</el-header>
        <el-main>
          <el-row :gutter="20">
            <el-col :span="10" class="task-area cloudy-glass">
              <el-card class="">
                Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sint quibusdam nemo et asperiores ducimus cum voluptate. Id ipsam at neque a sed? Dicta ducimus illum libero quas, fuga aliquid eum? Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sint quibusdam nemo et asperiores ducimus cum voluptate. Id ipsam at neque a sed? Dicta ducimus illum libero quas, fuga aliquid eum?
              </el-card>
              <el-card>
                <el-input
                  v-model="textarea"
                  style="width: 100%;"

                  :rows="20"
                  type="textarea"
                  placeholder="Please input"
                  @input="handleInput"
                  @copy="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"
                />
              <p v-html="highlightedText"></p>
            </el-card>
            </el-col>
            <el-col :span="14" class="chat-area cloudy-glass">
              <!-- Chat messages will go here -->
              <el-scrollbar>
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
              </el-scrollbar>
              <el-card class="bar">
                <el-input
                  v-model="userInput"
                  placeholder="Type your message here..."
                  @keyup.enter="sendMessage"
                  clearable
                >
                  <template #append>
                    <el-button type="primary" @click="sendMessage">
                      Send
                      <el-icon class="el-icon--right"><ArrowRight /></el-icon>
                    </el-button>
                  </template>
                </el-input>
              </el-card>
            </el-col>
          </el-row>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script>
import axios from "axios";
import { ref, computed } from 'vue';
import { onMounted } from 'vue';

export default {
  setup() {

    const messages = ref([]);
    const userInput = ref('');

    onMounted(() => {
  initialMessages();
  })
    
    
    const initialMessages = async ()=>{

      try {
        const { data } = await axios.get("/messages");
        messages.value = data.map( (chat)=>{
          return {
            id: chat.created_at,
            text: chat.response,
            sender: chat.role,
          }
        
        }); // Assuming the data is an array of messages
      } catch (error) {
        console.error("Failed to fetch initial messages:", error);
      }
    
    }

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


    // Todo event listeners
    const text = ref('');
    const highlightedText = computed(() => {
      const words = text.value.split(' ');
      return words
        .map((word) => {
          if (word.length > 5) {
            return `<span style="color: red">${word}</span>`;
          }
          return word;
        })
        .join(' ');
    });
    let focusTimeStart = 0;
    let focusTimeEnd = 0;

    const handleInput = () => {
      // No need to handle input event since v-model handles it automatically
    };

    const handleCopy = (e) => {
      console.log(e.clipboardData.getData('text/plain'));
      console.log('Copied Text:', window.getSelection().toString());
    };

    const handlePaste = async () => {
      const pastedText = await navigator.clipboard.readText();
      console.log('Pasted Text:', pastedText);
    };

    const handleMouseUp = () => {
      const selectedText = window.getSelection().toString();
      if (selectedText !== '') {
        console.log('Highlight Text:', selectedText);
      }
    };

    const startFocusTime = () => {
      if (focusTimeStart === 0) {
        focusTimeStart = new Date().getTime();
      }
    };

    const endFocusTime = () => {
      focusTimeEnd = new Date().getTime();
      console.log('Time Spent:', (focusTimeEnd - focusTimeStart) / 1000);
      focusTimeStart = 0;
    };


    return { messages, 
      userInput, 
      sendMessage,text,
      highlightedText,
      handleInput,
      handleCopy,
      handlePaste,
      handleMouseUp,
      startFocusTime,
      endFocusTime, };
  },
};
</script>

<style scoped>
/* Add your styles here */

.chat-area,
.task-area {
  margin: 20px;
}

.dashboard {
  display: flex;
  flex-direction: row; /* Change flex-direction to row */
}

.task-area {
  flex: 1; /* Take up remaining space */
  padding-right: 20px; /* Add some spacing between columns */
}

.chat-area {
  flex: 2;
  max-height: calc(100vh - 150px); /* Adjust the value based on your layout */
  overflow: auto; /* Add this line */
}

.message {
  margin-bottom: 20px;
}

.cloudy-glass {
  background: rgba(255, 255, 255, 0.15);
  box-shadow: 0 4px 2px 0 rgba(31, 38, 135, 0.15);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 20px;
}
.bar {
  position: sticky;
  bottom: 0;
  z-index: 1;
}
</style>

