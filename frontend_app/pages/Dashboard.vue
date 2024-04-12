<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-container class="dashboard" style="height:100%">
        <!-- <el-header>ChatGPT-like Chatbot</el-header> -->
        <el-main>
          <el-row :gutter="20"> ChatGPT-like Chatbot</el-row>
          <el-row :gutter="20">
            <el-col :span="10" class="task-area cloudy-glass">
              <el-card class="">
                Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sint quibusdam nemo et asperiores ducimus cum voluptate. Id ipsam at neque a sed? Dicta ducimus illum libero quas, fuga aliquid eum? Lorem ipsum dolor sit, amet consectetur adipisicing elit. Sint quibusdam nemo et asperiores ducimus cum voluptate. Id ipsam at neque a sed? Dicta ducimus illum libero quas, fuga aliquid eum?
              </el-card>
              <el-card class="note">

                <el-input
                  ref="textareaRef"
                  name="storage_notes"
                  v-model="textArea"
                  :autosize="{ minRows: 12, maxRows: 16}"
                  style="width: 100%;"
                  type="textarea"
                  placeholder="Leave some notes here..."
                  @input="handleInput($event, textArea)"

                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                 
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"
                />
                <div class="text-area_info">
                  <p>Word Count: {{ textAreaWordCount }}</p>
                  <el-button size="small" type="danger"  @click="clearTextArea" round >
                 
                  Clear  <DeleteFilled  style="width:16px; padding:2px;"/> </el-button>
                </div>

              <p>{{highlightedText}}</p>
            </el-card>
            </el-col>
            <el-col :span="14" class="chat-area cloudy-glass">
              <!-- Chat messages will go here -->
              <el-scrollbar>
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag>
                      <div :id="'user_question_' + message.id">{{ message.text }}</div>
                    </div>
                    <div v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag>
                      <div  :id="'ai_feedback_' + message.id" >{{ message.text }}</div>
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card class="bar">
                <el-input
                  name="prompt_input"
                  v-model="userInput"
                  placeholder="Type your message here..."
                  @keyup.enter="sendMessage"
                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"
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
import { ref} from 'vue';
import { onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import { watchEffect } from 'vue';

export default {
  setup() {

    const messages = ref([]);
    const textAreaWordCount = ref(0);
    const userInput = ref('');
    const textArea = ref('');
    const textareaRef = ref(null); // Add this line to define a ref for the textarea
    const highlightedText=ref('');
    const user_id = ref('anonymous');
    const route = useRoute();
   
    watchEffect(() => {
      
      if(sessionStorage.getItem('user_id')){
        user_id.value = JSON.parse(sessionStorage.getItem('user_id'));
         console.log('User ID:', user_id.value);
      }else{
        user_id.value = route.query.user_id || 'anonymous';
        if(user_id.value !== 'anonymous'){
          sessionStorage.setItem('user_id', JSON.stringify(user_id.value));
        
        }
      }
    
    });

    // console.log('Query Parameters:', route.query);
    onMounted(() => {
      document.addEventListener('keydown', handleHighlight);
      initialMessages();
      // Retrieve the value from session storage
      const storedValue = sessionStorage.getItem('storage_notes');
      if (storedValue) {
        textArea.value = storedValue;
        textAreaWordCount.value =storedValue.trim().split(/\s+|\n+/).length;
      }
    })

    // Don't forget to clean up the event listener on component unmount
    onUnmounted(() => {
      document.removeEventListener('keydown', handleHighlight);
    });
    
    
    const initialMessages = async ()=>{

      try {
        let api_url = "/messages";
        if(user_id.value !== 'anonymous'){
          api_url = `/messages?user_id=${user_id.value}`;
        } 
        const { data } = await axios.get(api_url);
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


    const sendBehavior= async (behavior)=>{
      if(behavior){
        let api_url = "/behavior";
        if(user_id.value !== 'anonymous'){
          api_url = `/behavior?user_id=${user_id.value}`;
        } 
        const { data } = await axios.post(api_url, behavior);
        console.log('Response Behavior',data);

      }
    }

    

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
        let api_url = "/openai";
        if(user_id.value !== 'anonymous'){
          api_url = `/openai?user_id=${user_id.value}`;
        } 
      const { data } = await axios.post(api_url, postData);
      console.log(data);
      createMessage(data.response, "assistant");
    }


    // Todo event listeners
    let focusTimeStart = 0;
    let focusTimeEnd = 0;
    const handleInput = (e, value) => {
      let inputValue;
      if (e && e.target) {
        inputValue = e.target.value;
      } else {
        inputValue = value;
      }

      if (inputValue !== undefined) {

        sessionStorage.setItem('storage_notes', inputValue);
        // console.log('Input Value:', inputValue, inputValue.split(/\s+|\n+/).length);
        const words = inputValue.trim().split(/\s+|\n+/);
        let previousWordCount = textAreaWordCount.value;
        // If the trimmed inputValue is empty, set word count to 0, else to the length of the words array
        textAreaWordCount.value = inputValue.trim() ? words.length : 0;
        if (previousWordCount !== textAreaWordCount.value) {
          console.log('Word Add/Remove:', inputValue);
          sendBehavior({
            id: Date.now(),
            content: inputValue,
            type: 'Word Add/Remove',
            target_object: 'textarea',
            log_time: new Date().toISOString(),
          })  
        }
      }
    };
    const clearTextArea = () => {
      textArea.value = '';
      textAreaWordCount.value = 0; // Explicitly set word count to 0 here
      sessionStorage.setItem('storage_notes', '');
      handleInput(null, ''); 
      //        id:,
        // chat_id:,
        // content:,
        // type:,
        // target_object:,
        // log_time:,
      sendBehavior({
        id: Date.now(),
        content: 'User Cleared TextBox',
        type: 'Clear',
        target_object: 'textarea',
        log_time: new Date().toISOString(),
      })  
      highlightedText.value='User Cleared TextBox:'
    };


    const handleCopy = (e) => {
      console.log(e.clipboardData.getData('text/plain'));
      console.log('Copied Text:', window.getSelection().toString());
      const targetElementName = e.target.name||e.target.id||e.target.nodeName;
      sendBehavior({
        id: Date.now(),
        content: window.getSelection().toString(),
        type: 'Copy',
        target_object: targetElementName,
        log_time: new Date().toISOString(),
      })
      highlightedText.value='Copied Text:'+window.getSelection().toString()+ ' from '+ targetElementName
    };

    const handlePaste = async (e) => {
      const pastedText = await e.clipboardData.getData('text');
      console.log('Pasted Text:', pastedText);
      const targetElementName = e.target.name||e.target.id||e.target.nodeName;
      sendBehavior({
        id: Date.now(),
        content: pastedText,
        type: 'Paste',
        target_object: targetElementName,
        log_time: new Date().toISOString(),
      })
      highlightedText.value='Copied Text:'+ pastedText + ' from '+ targetElementName
    };

    const handleHighlight = (e) => {
      
      if ((e.ctrlKey || e.metaKey) && e.key === 'a') {
        // Trigger your highlight logic here
        console.log('Ctrl+A or Command+A pressed');
        // Your existing logic for selecting text...
        let selectedText = '';
        if (textareaRef.value && textareaRef.value.$refs.textarea) {;
          const textarea = textareaRef.value.$refs.textarea;
          selectedText = textarea.value;
        }
        //  console.log('select:', selectedText);
        if (selectedText) {
          console.log('Selected Text:', selectedText);
          const targetElementName = e.target.name||e.target.id||e.target.nodeName;
          sendBehavior({
            id: Date.now(),
            content: selectedText,
            type: 'HighlightAll',
            target_object: targetElementName,
            log_time: new Date().toISOString(),
          })
          highlightedText.value = 'Selected Text: ' + selectedText + ' from '+ targetElementName;
        } 
      }
    };



    const handleMouseUp = (e) => {
      console.log('Mouse Up');

      let selectedText = '';
      // Check if the event's target is the textarea
      if (e.target === textareaRef.value.$refs.textarea) {
        const start = e.target.selectionStart;
        const end = e.target.selectionEnd;
        selectedText = e.target.value.substring(start, end);
      } else {
        // For other elements, continue using window.getSelection
        selectedText = window.getSelection().toString();
      }
      if (selectedText !== '') {
        // Do something with the selected text
        console.log('Highlight Text:', selectedText);
        const targetElementName = e.target.name||e.target.id||e.target.nodeName;
        // targetElementName.split('_');
        sendBehavior({
          id: Date.now(),
          content: selectedText,
          type: 'Highlight',
          target_object: targetElementName,
          log_time: new Date().toISOString(),
        })
        highlightedText.value='Highlight Text:'+ selectedText+ ' from '+ targetElementName;
      }
      // Update the session storage
      // console.log('textArea Text:', textArea.value);
      // sessionStorage.setItem('storage_notes', textArea.value);

    };

    const startFocusTime = () => {
      if (focusTimeStart === 0) {
        focusTimeStart = new Date().getTime();
      }
    };

    const endFocusTime = () => {
      focusTimeEnd = new Date().getTime();
      console.log('Time Spent:', (focusTimeEnd - focusTimeStart) / 1000);
      highlightedText.value='Focus Time Spent:'+ (focusTimeEnd - focusTimeStart) / 1000
      sendBehavior({
        id: Date.now(),
        content: (focusTimeEnd - focusTimeStart) / 1000,
        type: 'focus_time',
        target_object: 'textarea',
        log_time: new Date(focusTimeEnd).toISOString(),
      })
      focusTimeStart = 0;
    };

    document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      console.log('User is focused on the page');
      // Perform actions when the page is in focus
      sendBehavior({
            id: Date.now(),
            content: 'User is focused on the page',
            type: 'concentration',
            target_object: 'page',
            log_time: new Date().toISOString(),
       })  
       highlightedText.value='User is focused on the page'

    } else {
      console.log('User has left the page');
      // Perform actions when the page is not in focus
       highlightedText.value='User has left the page'
            sendBehavior({
            id: Date.now(),
            content: 'User has left the page',
            type: 'concentration',
            target_object: 'page',
            log_time: new Date().toISOString(),
       })  
    }
    });


    return { messages, 
      userInput, 
      textArea,
      textAreaWordCount,
      handleInput,
      clearTextArea,
      textareaRef,
      sendMessage,
      highlightedText,
      handleHighlight,
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
  position: relative;
  padding-bottom: 60px !important;
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
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0; /* Add this to make the bar span the entire width */
  z-index: 1;
}
.note {
  margin-top: 20px;
  max-height: 100%;
  overflow: hidden;
}
.text-area_info{
  display: flex;
  justify-content: space-between;
  margin-top: 4px;
}
</style>

