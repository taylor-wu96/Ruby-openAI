<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-container class="dashboard" style="height:100%">
        <!-- <el-header>ChatGPT-like Chatbot</el-header> -->
        <el-main>
          <el-row :gutter="20" class="brand-area">
            <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px; margin-right: 10px;" /> 
            <span class="brand-class">
              Cohere AI | Your Personal AI Workspace
            </span> 
            <el-button style="margin-left:4px;" ref="infoRef" size="small" circle type="info" icon="InfoFilled" @click="open = true">
            </el-button>
             </el-row>
          <el-row  :gutter="20">
            <!-- :span="10" :span="14" -->
            <el-col :xs="24" :sm="24" :md="24" :lg="12" :xl="10" class="task-area cloudy-glass">
              <el-card ref="scenarioRef" class="scenario">
                <div class="scenario-title">
                  Scenario
                </div>
                <div  v-html="scenarioText">
                </div>
              </el-card>
              <el-card ref="noteRef" class="note">
                <div class="scenario-title">
                  Your Answer
                </div>
                <!--  :autosize="{ minRows: 4, maxRows:10}" -->
                <el-input
                  ref="textareaRef"
                  name="storage_notes"
                  v-model="textArea"
                  type="textarea"
                  placeholder="Leave some notes here..."
                  :autosize="{ minRows: 8 , maxRows: 8}"
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
                  <el-text> {{ textAreaWordCount }} / words</el-text>
                  <el-button size="small" type="danger"  @click="clearTextArea" round >
                  Reset  <DeleteFilled  style="width:20px; padding:2px 0px 2px 4px;"/> </el-button>
                </div>
              <el-form ref="submitTaskRef" :model="form" label-width="auto" >
                  <div class="submit_block">
                     <el-form-item label="I have finished the answer">
                        <el-switch v-model="hasFinishTask" :before-change="checkTaskFinish" :active-icon="Check" :inactive-icon="Close" />
                      </el-form-item>
                      <el-form-item>
                        <el-button  type="info"  :disabled="!hasFinishTask" round @click="onSubmitTask">Submit</el-button>
                      </el-form-item>

                  </div>
                 
              </el-form>
              <!-- <p>{{highlightedText}}</p> -->

            </el-card>
            </el-col>
            <el-col v-if="!mobileDrawer" ref="chatBotRef"  :xs="22" :sm="22" :md="22" :lg="12" :xl="14" class="chat-area cloudy-glass invisible">
              <!-- Chat messages will go here -->
              <div >
                  <el-popover
                    placement="top-start"
                    title="Task AI"
                    :width="400"
                    trigger="hover"
                    content="Task AI is a chatbot powered by GPT-3. It can help you with various tasks. especially for text-related tasks."
                  >
                    <template #reference>
                       <el-text  size="large" tag="b" class="chat-title">Task AI 
                  <el-tag size="small" type='info' effect="dark"
                  round>Powered by GPT</el-tag>   </el-text>  
                    </template>
                  </el-popover>
              </div>
              <el-scrollbar>
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar class="avatar user-bg" icon="UserFilled" />
                      <div>
                        <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag>
                        <div :id="'user_question_' + message.id">{{ message.text }}</div>
                         
                      </div>

                    </div>
                    <div  class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar class="avatar bot-bg"   icon="ChatLineRound" />
                      <div>
                        <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag>
                        <div  :id="'ai_feedback_' + message.id" >{{ message.text }}</div>
                        <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip>
                        <!-- :id="'icon_' + message.id"  :id="'button_' + message.id" :id="'template_' + message.id" :id="'tooltip_' + message.id" :id="'copy_' + message.id" -->


                      </div>
                     
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card ref="chatInputRef" class="bar">
                <el-input
                  id="prompt_input"
                  class="prompt_input"
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
                    <el-button class="submit-chatbot" @click="sendMessage">
                      
                      <!-- <div class="submit-chatbot-text">Send</div> -->
                      <Promotion style="width:24px; vertical-align:middle;  padding:0;" />
                    </el-button>
                  </template>
                </el-input>
              </el-card>
            </el-col>
          </el-row>
        </el-main>
        <!-- Drawer Code For  Mobile -->
        <el-button v-if="mobileDrawer" ref="chatBotRef" class="mobile-drawer"  style="margin-left: 16px" @click="drawer = true">
            <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px;" /> 
        </el-button>

        <el-drawer class="inner-drawer" v-model="drawer" size="80%" title="Task AI" >
           <div class="chat-area cloudy-glass">
              <el-scrollbar>
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar class="avatar user-bg" icon="UserFilled" />
                      <div>
                        <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag>
                        <div :id="'user_question_' + message.id">{{ message.text }}</div>
                         
                      </div>

                    </div>
                    <div class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar class="avatar bot-bg"  icon="ChatLineRound" />
                      <div>
                        <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag>
                        <div  :id="'ai_feedback_' + message.id" >{{ message.text }} </div>
                        <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip>
                        <!-- :id="'icon_' + message.id"  :id="'button_' + message.id" :id="'template_' + message.id" :id="'tooltip_' + message.id" :id="'copy_' + message.id" -->


                      </div>
                     
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card  ref="chatInputRef"  class="bar">
                <el-input
                  id="prompt_input"
                  class="prompt_input"
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
                    <el-button class="submit-chatbot" @click="sendMessage">
                      <Promotion style="width:24px; vertical-align:middle;  padding:0;" />
                    </el-button>
                  </template>
                </el-input>
              </el-card>
            </div>
        </el-drawer>

        <!-- Tour Code -->
      


        <el-tour mask v-model="open" type="primary" >
          <!-- <el-tour-step
            :target="ref1?.$el"
            title="Upload File"
            description="Put you files here."
          />
          <el-tour-step
            :target="ref2?.$el"
            title="Save"
            description="Save your changes"
          />
          <el-tour-step
            :target="ref3?.$el"
            title="Other Actions"
            description="Click to see other"
          /> -->
          <!-- scenarioRef,
          noteRef,
          chatBotRef,
          submitTask,
          infoRef, -->
          <el-tour-step title="Introduction">
            <h1>About this experiment:</h1>
            <div>This experiment is want to know how will you finish the task. you have the right use the chatbot. it is same as the gpt you use</div>
          </el-tour-step>
          <el-tour-step
            :target="scenarioRef?.$el"
            title="Scenario Block"
            description="In this part, you will see the scenario of the task. you should follow the instructions to finish the task."
          />
          <el-tour-step
            :target="noteRef?.$el"
            title="Note Block"
            description="You can keep all of your note and task here before submission. you can see the word count below the text area."

          />
          <el-tour-step
            placement="left"
            :target="chatBotRef?.$el"
            title="Task AI Block"
            description="This the normal llm chatbot you can use. you can ask any question to the chatbot help you finish the task. Need to scroll down to see the latest message."
          />
          <el-tour-step
            :target="chatInputRef?.$el"
            title="chatInputRef"
            description="Type the question here and click the send button to send the message to the chatbot."
          />
          <el-tour-step
            :target="submitTaskRef?.$el"
            title="Submit Task"
            description="After you finish the task, you should turn on the toggle I have finished the answer, you can click the submit button to submit the task."
          />

          <el-tour-step
            :target="infoRef?.$el"
            title="Want to see the tour again?"
            description="Just click this button to see the tour again."
          />
        </el-tour>

      </el-container>
    </el-container>
  </div>
</template>

<script>
import Constants from "../constant/Constants.vue";
import axios from "axios";
import { ref} from 'vue';
import { onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import { watchEffect } from 'vue';
import { ElMessage } from 'element-plus'


export default {
  setup() {

    const drawer = ref(false)
    const hasFinishTask = ref(false);
    const messages = ref([]);
    const textAreaWordCount = ref(0);
    const scenarioText = ref('');
    const minWords = 160;
    const maxWords = 300;
    const userInput = ref('');
    const textArea = ref('');
    const textareaRef = ref(null); // Add this line to define a ref for the textarea
    const highlightedText=ref('');
    const user_id = ref('anonymous');
    const route = useRoute();

    //  test for tour
    const chatInputRef = ref(null)
    // const ref2 = ref(null)
    // const ref3 = ref(null)
    const scenarioRef = ref(null)
    const noteRef = ref(null)
    const chatBotRef = ref(null)
    const submitTaskRef = ref(null)
    const infoRef = ref(null)
    const mobileDrawer = ref(window.innerWidth<992?true:false)

    const open = ref(true)

   
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
      getTask();
    })

    // Don't forget to clean up the event listener on component unmount
    onUnmounted(() => {
      document.removeEventListener('keydown', handleHighlight);
    });

    // Error Prevention
    const checkTaskFinish= () => {
      if(textAreaWordCount.value>minWords && textAreaWordCount.value<maxWords){
        return new Promise((resolve) => {
          setTimeout(() => {
            ElMessage.success('Switch success')
            return resolve(true)
          }, 100)
        })
      }else{
        // console.log('Task Not Finished:', value);
          return new Promise((_, reject) => {
            setTimeout(() => {
              ElMessage.error(`Task not finished. Please write between ${minWords} and ${maxWords}  words.`)
              return reject(new Error('Error'))
            }, 100)
          })
      }
    }
    
    // API related
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


    // const sendBehavior= async (behavior)=>{
    //   if(behavior){
    //     let api_url = "/behavior";
    //     if(user_id.value !== 'anonymous'){
    //       api_url = `/behavior?user_id=${user_id.value}`;
    //     } 
    //     const { data } = await axios.post(api_url, behavior);
    //     console.log('Response Behavior',data);

    //   }
    // }

  const sendBehavior = async (behavior) => {
  if (behavior) {
    let api_url = "/behavior";
    if (user_id.value !== 'anonymous') {
      api_url = `/behavior?user_id=${user_id.value}`;
    }
    try {
      const { data } = await axios.post(api_url, behavior);
      console.log('Response Behavior', data);
    } catch (error) {
      console.error('Failed to send behavior:', error);
      // Handle specific error scenarios here if needed
    }
  }
}
  const getTask = async () => {
    try {
      let api_url = "/random-task";
      if(user_id.value !== 'anonymous'){
        api_url = `/random-task?user_id=${user_id.value}`;
      } 
      const { data } = await axios.get(api_url);
      console.log('Task:', data);
      console.log('Task:', data.task_name);
      if(data.task_name==='creative'){
        // createMessage(data.task_name, "assistant");
        scenarioText.value = Constants.CREATIVE;
      }
      else{
        scenarioText.value = Constants.PRACTICAL;
      }
    } catch (error) {
      console.error('Failed to fetch task:', error);
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


    // Event listeners
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
      sendBehavior({
        id: Date.now(),
        content: 'User Cleared TextBox',
        type: 'Clear',
        target_object: 'textarea',
        log_time: new Date().toISOString(),
      })  
      highlightedText.value='User Cleared TextBox:'
    };

    const handleCopiedButton = async(e) => {
      // console.log(e.target);
      let targetElement = e.target;
      if(!targetElement.id){
        targetElement = e.target.parentElement;
      }
      // console.log(targetElement.id);
      const messageId = targetElement.id.split('_')[1]; // Extract the message ID from the parent element's ID
      const aiResponseElement = document.getElementById(`ai_feedback_${messageId}`);
      console.log('Response element:', aiResponseElement);
      const copiedText = aiResponseElement.textContent;
      console.log('Copied Text:', copiedText);

      console.log('Copied Button');
      sendBehavior({
        id: Date.now(),
        content: copiedText,
        type: 'Copy',
        target_object: aiResponseElement.name||aiResponseElement.id||aiResponseElement.nodeName,
        log_time: new Date().toISOString(),
      })

      const tempInput = document.createElement('textarea');
      tempInput.value = copiedText;
      document.body.appendChild(tempInput);
      tempInput.select();
      document.execCommand('copy');
      document.body.removeChild(tempInput);

      highlightedText.value='Copied from Button: '+copiedText
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
    
    window.addEventListener('resize', () => {
      if(window.innerWidth<992){
        console.log("Window width:", window.innerWidth); 
        console.log('Mobile View');
        mobileDrawer.value = true;
      }
      else{
        mobileDrawer.value = false;
      }
    })

    const onSubmitTask = async () => {
      console.log('Task Submitted:', textArea.value);
      sendBehavior({
        id: Date.now(),
        content: textArea.value,
        type: 'Task Submission',
        target_object: 'textarea',
        log_time: new Date().toISOString(),
      })
      highlightedText.value='Task Submitted:'+ textArea.value
    };

    return { messages, 
      userInput, 
      scenarioRef,
      noteRef,
      chatBotRef,
      submitTaskRef,
      chatInputRef,
      infoRef,
      open,
      scenarioText,
      textArea,
      textAreaWordCount,
      checkTaskFinish,
      onSubmitTask,
      handleInput,
      handleCopiedButton, 
      clearTextArea,
      textareaRef,
      sendMessage,
      highlightedText,
      handleHighlight,
      handleCopy,
      handlePaste,
      handleMouseUp,
      startFocusTime,
      hasFinishTask,
      endFocusTime,
      drawer,
      mobileDrawer, };
  },
};
</script>

<style scoped>
/* Add your styles here scoped */

.chat-area,
.task-area {
  margin: 10px 10px;
  max-height: calc(100vh - 100px); /* Adjust the value based on your layout */
  height:calc(100vh - 100px) ;
}
.brand-area{
  padding: 0 20px;
  display: flex;
  align-items: center;
  
}
.brand-class{
  font-weight: bold;
  font-size: 1.25rem;
}

.dashboard {
  display: flex;
  flex-direction: row; /* Change flex-direction to row */
  flex: 1; /* Added */
  height: 100%; /* Added */
}

.task-area {
  display: flex; /* Added */
  flex-direction: column; /* Added */
  flex: 1; /* Take up remaining space */
  padding-right: 20px; /* Add some spacing between columns */
}

.chat-area {
  flex: 2;
 
  position: relative;
  padding-bottom: 120px !important;
  }

.message {
  margin-bottom: 20px;
}

.cloudy-glass {
  background: rgba(255, 255, 255, 0.45);
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
.scenario,
.note {
  /* margin-top: 20px; */
  /* max-height: 100%; */
  max-height: 49%;
  min-height: 49%;
  /* height: calc(50%-5px); */
  overflow: scroll;
  flex: 1; /* Added */
}
.note{
  margin-top: 10px;

}
.text-area_info{
  display: flex;
  align-items: center;
  gap: 20px;
  /* justify-content: space-between; */
  margin-top: 8px;
}
.chat-title{
  display: flex;
  gap: 4px;
  align-items: center;
  padding: 10px 0;
}

.bar>>>.el-input{
  width: 100%;
  border-radius: 25px;
  background: #E9EEF6 ;
  padding: 8px 16px ;

}

.bar>>>.el-input__wrapper,
.bar>>>.el-input-group__append

 {
  /* width: 100%; */
  border-radius: 0;
  font-size: 1rem;
  /* border-radius: 100px !important ; */
  /* border: 4px solid #dcdfe6; */
  box-shadow: none;
  background: transparent;
  line-height: 4;
  padding: 4px 8px;
  color: #5F6367;
  /* background-color: #ffffff; */

}



.bar>>>.el-input-group__append{
  background: #1b1b1b;
  color: #ffffff;
  border-radius: 16px ;
  padding: 0px 12px 8px 12px;
  
  vertical-align: middle;
  /* border: 2px #6b8ea2 solid; */
  /* font-size: 0.8rem; */
}
.bar>>>.el-input-group__append>span {
 display: flex !important;
 align-items: center;
 justify-content: center;
}
.note>>>.el-textarea{
  height: 100%;

}
.note>>>.el-textarea__inner{
  border-radius: 10px;
  border: none;
  background: #E9EEF6;
  padding: 10px;
  resize: none;
  display: block;
  height: 100%;
  min-height: 100% !important;
  /* max-height: 100%; */
}
.bar{
  background: transparent;
  box-shadow: none;
  border-radius: 0;
 

}

.task-area>>>.el-card,
.chat-area>>>.el-card{
  background: #ffffff;
  box-shadow: none;
  border: none;
  border-radius: 10px;
}


.dialogue{
  display: flex;
  align-items: start;
  gap: 12px;
}

.avatar{
  flex-shrink: 0;
}
.user-bg{
  background: #409EFF;
}
.bot-bg{
  background: #67C23A;
}

.scenario-title{
  font-size: 1.1rem;
  font-weight: bold;
  margin-bottom: 10px;
}

.submit_block{

  display: flex;
  justify-content: space-between;
  align-items: center;
}

.mobile-drawer{
  position: fixed;
  display: flex;
  width: 50px;
  height: 50px;
  align-items: center;
  justify-content: center;
  vertical-align: middle;
  right: 30px;
  bottom: 30px;
  z-index: 1000;
  box-shadow: #5F6367 0px 0px 10px 0px;
  padding: 10px;
  border: none;
  border-radius: 50%;
  background: #1b1b1b;
  transition: all 0.3s;
}
.mobile-drawer>span{
  display: flex;
  align-items: center;
  justify-content: center;
}

.inner-drawer{
  background-color: rgb(158, 158, 158) !important;
}
@media (min-width:992px) {
  .mobile-drawer{
    display: none;
  }
}
@media (max-width:992px) {
  .invisible{
    display: none !important;
  }
}


</style>

