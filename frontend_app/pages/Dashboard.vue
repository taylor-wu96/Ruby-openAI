<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-container class="dashboard" style="height:100%">
        <!-- <el-header>ChatGPT-like Chatbot</el-header> -->
        <el-main>
          <el-row :gutter="20" class="brand-area">
            <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px; margin-right: 10px;" /> 
            <div class="brand-class">
              Cohere AI | Your Personal AI Workspace
            </div> 
            <el-button style="margin-left:8px;" round ref="infoRef" size="small" type="info" icon="InfoFilled" @click="open = true">
              Help
            </el-button>
             </el-row>
          <el-row  :gutter="20">
            <el-col :xs="24" :sm="24" :md="24" :lg="13" :xl="13" class="task-area cloudy-glass">
              <el-card ref="scenarioRef" class="scenario">
                <div class="scenario-title">
                  <!-- Scenario -->
                  Your Task
                </div>
                <div  v-html="scenarioText">
                </div>
              </el-card>
              <el-card ref="noteRef" class="note">
                <el-scrollbar always max-height="100%" height="100%">
                  <div class="scenario-title">
                  Your Answer
                  <el-text size="small" tag="i"> Enter the all of task in the following input field </el-text>
                </div>

                <!--  :autosize="{ minRows: 4, maxRows:10}" -->
                <el-input
                  ref="textareaRef"
                  name="NoteArea"
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
                  <!-- <el-button size="small" type="danger"  @click="clearTextArea" round >
                  Reset  <DeleteFilled  style="width:20px; padding:2px 0px 2px 4px;"/> </el-button> -->
                </div>
                <el-form ref="submitTaskRef"  label-width="auto" >
                    <div class="submit_block">
                      <el-form-item label="I have finished the answer">
                        <!-- active-icon="Check" inactive-icon="Close" -->
                          <el-switch v-model="hasFinishTask" :before-change="checkTaskFinish"  />
                        </el-form-item>
                        <el-form-item>
                          <el-button  type="info"  :disabled="!hasFinishTask" round @click="onSubmitTask">Submit</el-button>
                        </el-form-item>

                    </div>
                  
                </el-form>
                <!-- <p>{{highlightedText}}</p> -->

                </el-scrollbar>
                

            </el-card>
            </el-col>
            <el-col v-if="!mobileDrawer" ref="chatBotRef"  :xs="24" :sm="24" :md="24" :lg="11" :xl="11" class="chat-area cloudy-glass invisible">
              <!-- Chat messages will go here -->
              <div style="padding:5px 4px">
                  <el-popover
                    placement="top-start"
                    title="Airport Helper"
                    :width="400"
                    trigger="hover"
                    content="Airport Helper is a chatbot powered by GPT-3. It can help you with various tasks. especially for text-related tasks."
                  >
                    <template #reference>
                       <el-text  size="large" tag="b" class="chat-title"> Airport Helper
                  <el-tag size="small" type='info' effect="dark"
                  round>Powered by GPT</el-tag>   </el-text>  
                    </template>
                  </el-popover>
              </div>
              <el-scrollbar max-height="100%" height="100%" ref="scrollContainer">
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar user-bg" icon="UserFilled" />
                      <div>
                         <div class="user-title"  :id="'user_question_tag_' + message.id">
                          You
                        </div>
                        <!-- <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag> -->
                        <div :id="'user_question_' + message.id">{{ message.text }}</div>
                      </div>

                    </div>
                    <div  class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar bot-bg"   icon="ChatLineRound" />
                      <div>
                        <div class="user-title"  :id="'ai_feedback_tag_' + message.id" >
                          Chatbot
                        </div>
                        <!-- <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag> -->
                        <div  :id="'ai_feedback_' + message.id" >{{ message.text }}</div>
                        <!-- <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip> -->
                        <span v-if="isLastChatbotMessage(message)">
                          <el-button :disabled="MIN_TEMP>=currentTemp" @click="resentMessage(false)" size="small" type="info" plain round>
                           Give me more various idea!
                          </el-button>
                          <el-button :disabled="MAX_TEMP<=currentTemp" @click="resentMessage(true)" size="small" type="info" plain round>
                            Give me more cautious idea!
                          </el-button>

                        </span>                     
                      </div>
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card ref="chatInputRef" class="bar">
                <!-- <el-input
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
                </el-input> -->
                <el-input
                  type="textarea"
                  :autosize="{ minRows: 1 , maxRows: 6}"
                  id="PromptArea"
                  class="prompt_input"
                  name="PromptArea"
                  v-model="userInput"
                  placeholder="Type your message here..."
                  resize="none"
                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"

                >
                </el-input>
                <el-button class="submit-chatbot" @click="sendMessage">      
                      <Promotion style="width:24px; vertical-align:middle;  padding:0;" />
                </el-button>
              </el-card>
            </el-col>
          </el-row>
        </el-main>
        <!-- Drawer Code For  Mobile -->
        <el-button v-if="mobileDrawer" ref="chatBotRef" class="mobile-drawer"  style="margin-left: 16px" @click="drawer = true">
            <img src="../static/logo.png" alt="PopAi" style="width: 36px; height: 36px;" /> 
        </el-button>

        <!-- @closed="scrollToBottom()"  -->
        <el-drawer class="inner-drawer" @open="scrollToBottom();" v-model="drawer" size="80%" title="Airport Helper" >
           <div class="m-chat-area">
              <el-scrollbar class="scroll-bar" ref="scrollContainer">
                <div  v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar user-bg" icon="UserFilled" />
                      <div>
                        <div class="user-title"  :id="'user_question_tag_' + message.id">
                          You
                        </div>
                        <!-- <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag> -->
                        <div :id="'user_question_' + message.id">{{ message.text }}</div>
                         
                      </div>

                    </div>
                    <div class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar bot-bg"  icon="ChatLineRound" />
                      <div>
                        <div class="user-title" :id="'ai_feedback_tag_' + message.id">
                          Chatbot
                        </div>
                        <div  :id="'ai_feedback_' + message.id" >{{ message.text }} </div>
                      
                        <span v-if="isLastChatbotMessage(message)">
                          <el-button :disabled="MIN_TEMP>=currentTemp" @click="resentMessage(false)" size="small" type="info" plain round>
                            Retry with more concreteness idea!
                          </el-button>
                          <el-button :disabled="MAX_TEMP<=currentTemp" @click="resentMessage(true)" size="small" type="info" plain round>
                            Retry with more abstract idea!
                          </el-button>

                        </span>

                      </div>
                     
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card ref="chatInputRef" class="bar">
                <el-input
                  type="textarea"
                  :autosize="{ minRows: 1 , maxRows: 6}"
                  id="prompt_input"
                  class="PromptArea"
                  name="PromptArea"
                  v-model="userInput"
                  placeholder="Type your message here..."
                  resize="none"
                  @keydown.ctrl.a="handleHighlight"
                  @keydown.meta.a="handleHighlight"
                  @copy="handleCopy"
                  @cut="handleCopy"
                  @paste="handlePaste"
                  @mouseup="handleMouseUp"
                  @focusin="startFocusTime"
                  @focusout="endFocusTime"
                >
                </el-input>
                <el-button class="submit-chatbot" @click="sendMessage">      
                      <Promotion style="width:24px; vertical-align:middle;  padding:0;" />
                </el-button>
              </el-card>
            </div>
        </el-drawer>

        <!-- Tour Code -->

        <el-tour :show-close="false" @finish="tourFinished" :mask="{ color: '#000000df', }" v-model="open" type="default" >
          <el-tour-step title="Introduction">
            <h1>About this experiment:</h1>
            <div>This experiment is want to know how you will finish the task in the scenario. In the experiment, you have the right to unlimited use the chatbot. it is same as the ChatGPT and other kinds of AI tools you use</div>
          </el-tour-step>
         
          <el-tour-step
            :target="scenarioRef?.$el"
            title="Scenario Block"
            description="In this part, you will understand the scenario of the task.In this experiment, you should follow the requirement of the scenario to finish the task."
          />
          <el-tour-step
            :target="noteRef?.$el"
            title="Note Block"
            description="You can keep all of your notes and task here before submission. you can see the word count below the text area."

          />
               <!-- placement="left-start" -->
          <el-tour-step
            :placement="!mobileDrawer?'left':'top-start'"
            :target="chatBotRef?.$el"
            title="Airport Helper Block"
            description="This airPort Helper is an AI chatbot services. It can help you to generate with your idea. You may need to scroll down to see the latest message."
          />

          <el-tour-step
            :target="chatInputRef?.$el"
            title="Input Block"
            description="Type the question you want to ask AI here and click the send button to send the message to the chatbot."
          />
          <el-tour-step
            :target="submitTaskRef?.$el"
            title="Submit Task"
            description="After you finish the task, you should turn on the toggle I have finished the answer first, amd then you can click the submit button to submit your task."
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
import { ref, watch, nextTick } from 'vue';
import { onMounted, onUnmounted } from 'vue';
import { useRoute } from 'vue-router';
import { watchEffect } from 'vue';
import { ElMessage,ElNotification  } from 'element-plus'


export default {
  setup() {

    const drawer = ref(false)
    const hasFinishTask = ref(false);
    const ipAddress = ref('');
    const messages = ref([]);
    const textAreaWordCount = ref(0);
    const scenarioText = ref('');
    const minWords = 2;
    const maxWords = 300;
    const userInput = ref('');
    const textArea = ref('');
    const textareaRef = ref(null); // Add this line to define a ref for the textarea
    const highlightedText=ref('');
    const route = useRoute();
    const user_id = ref('anonymous');
   

    const currentTemp=ref(Constants.DEFAULTS_TEMP)
    const MAX_TEMP=Constants.MAX_TEMP
    const MIN_TEMP=Constants.MIN_TEMP

    //  test for tour
    const chatInputRef = ref(null)
    const scenarioRef = ref(null)
    const noteRef = ref(null)
    const chatBotRef = ref(null)
    const submitTaskRef = ref(null)
    const infoRef = ref(null)
    const scrollContainer = ref(null);


    const mobileDrawer = ref(window.innerWidth<992?true:false)
    const open = ref(true)
    let localData ={}


    watchEffect(async () => {
      // ...
      user_id.value = route.query.user_id || 'anonymous';
      localData['user_id'] = user_id.value
      if (!localStorage.getItem(user_id.value)) {
        localStorage.setItem(user_id.value, JSON.stringify(localData));
        console.log('Local Data:', localData);
      } else {
        const data = await localStorage.getItem(user_id.value);
        localData = JSON.parse(data);
        console.log('Local Data:', localData);
        textArea.value = localData['storage_notes']||'';
        if(textArea.value){
          textAreaWordCount.value = textArea.value.trim().split(/\s+|\n+/).length;
        }
        if(localData['tour']===false){
          open.value = localData['tour'];
        }
      }
    });

    watch(messages, () => {
      // Wait for the next DOM update to scroll
      nextTick(() => {
        scrollToBottom();
      });
    }, { deep: true });


    // console.log('Query Parameters:', route.query);
    onMounted(async() => {

      document.addEventListener('keydown', handleHighlight);
      
      await initialMessages();
      await getTask();
      await getIPFromAmazon();
      await updateIp();
    })

    // Don't forget to clean up the event listener on component unmount
    onUnmounted(() => {
      document.removeEventListener('keydown', handleHighlight);
    });


    // Tour 
    const tourFinished = () => {
      console.log('Tour Finished');
      localData['tour']=false;
      localStorage.setItem(user_id.value, JSON.stringify(localData));
    };


    // Chat to bottom
    async function scrollToBottom() {
      try{
        if (scrollContainer.value) {
          scrollContainer.value.setScrollTop(1e16);
        }
      }catch(error){
        console.error('Failed to scroll to bottom:', error);
      }
      // scrollContainer.value.setScrollTop(1e16);
    }

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
        nextTick(() => {
          scrollToBottom();
        });
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
      else{
        ElNotification({
          title: 'Notice',
          message: "The message can't be empty!",
          type: 'warning',
        })
      }
    };


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
        scenarioText.value = Constants.CREATIVE;
      }
      else{
        scenarioText.value = Constants.PRACTICAL;
      }
    } catch (error) {
      console.error('Failed to fetch task:', error);
    }
  }

  const onSubmitTask = async () => {
    try {
      let api_url = "/submit-task";
      if(user_id.value !== 'anonymous'){
        api_url = `/random-task?user_id=${user_id.value}`
        ;
      } 
      const { data } = await axios.post(api_url,{task_description: textArea.value});
      ElNotification({
          title: 'Finish',
          message: "You have Successfully Submit the task!",
          type: 'success',
      })
    } catch (error) {
      console.error('Failed to fetch task:', error);
    }
  }

  const updateIp = async () => {
    try {
      let api_url = "/update_ip";
      if(user_id.value !== 'anonymous'){
        api_url = `/update_ip?user_id=${user_id.value}`
        ;
      } 
      const { data } = await axios.post(api_url,{ip_address: ipAddress.value});
      ElNotification({
          title: 'Finish',
          // message: "You have Successfully Submit the task!",
          type: 'success',
      })
    } catch (error) {
      console.error('Failed to update IP:', error);
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
        temp: currentTemp.value,
      });
    }
    // Get response from the backend

    async function getResponse(message) {
      const postData = {
        message_content: message,
        system_temp: currentTemp.value,
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

        localData['storage_notes']=inputValue
        localStorage.setItem(user_id.value, JSON.stringify(localData));
        // localStorage.setItem('storage_notes', inputValue);
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
            target_object: 'NoteArea',
            log_time: new Date().toISOString(),
          })  
        }
      }
    };
    const clearTextArea = () => {
       ElMessageBox.confirm('Are you sure to delete all of the text?')
        .then(() => {
          textArea.value = '';
          textAreaWordCount.value = 0; // Explicitly set word count to 0 here
          localData['storage_notes']=''
          localStorage.setItem(user_id.value, JSON.stringify(localData));

          handleInput(null, ''); 
          sendBehavior({
            id: Date.now(),
            content: 'User Cleared TextBox',
            type: 'Clear',
            target_object: 'textarea',
            log_time: new Date().toISOString(),
          })  
          highlightedText.value='User Cleared TextBox:'
          done()
        })
        .catch((err) => {

          // catch error
        })

     
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
      // localStorage.setItem('storage_notes', textArea.value);

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
            content: 'User is focused on the page on' + Date.now().toString(),
            type: 'Concentration',
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
            content: 'User has left the page on' + Date.now().toString(),
            type: 'Concentration',
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

    // const onSubmitTask = async () => {
    //   console.log('Task Submitted:', textArea.value);
    //   sendBehavior({
    //     id: Date.now(),
    //     content: textArea.value,
    //     type: 'Task Submission',
    //     target_object: 'textarea',
    //     log_time: new Date().toISOString(),
    //   })
    //   highlightedText.value='Task Submitted:'+ textArea.value
    // };


    // The UI conditions parts
    const isLastChatbotMessage = (message) => {
      const lastIndex = messages.value.length - 1;
      const lastMessage = messages.value[lastIndex];
      return message.id === lastMessage.id && lastMessage.sender === 'assistant';
    };

    // Resent the chatbot message
    const resentMessage = (up) => {
      const RESENT_PROMPT="Give me another idea?"
      if(up){
        currentTemp.value+=0.1;
      }
      else{
        currentTemp.value-=0.1;
      }
      createMessage(RESENT_PROMPT,'user')
      getResponse(RESENT_PROMPT)
    };


    // Listen the ipAddress
    const getIPFromAmazon=async()=> {
      fetch("https://checkip.amazonaws.com/").then(res => res.text()).then(data => {
        ipAddress.value = data;
        console.log('IP: '+data)
        })
    }

    return { messages, 
      userInput, 
      scenarioRef,
      noteRef,
      chatBotRef,
      submitTaskRef,
      chatInputRef,
      infoRef,
      open,
      tourFinished,
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
      mobileDrawer,
      scrollToBottom,
      scrollContainer,
      isLastChatbotMessage,
      MAX_TEMP,
      MIN_TEMP,
      currentTemp,
      resentMessage,};
  },
};
</script>

<style scoped>
/* Add your styles here scoped */

*{
  /* font: 'Arial' !important; */
  -webkit-font-smoothing: antialiased;
  /* color: #2c2c2cdf !important; */
}

.chat-area,
.task-area {
  margin: 10px 10px;
  max-height: calc(100vh - 100px); /* Adjust the value based on your layout */
  height:calc(100vh - 100px) ;
}
.m-chat-area{
  width: 100%;
  height: 100%;
  flex: 2;
  position: relative;
  padding-bottom: 80px !important;
  
}
.m-chat-area>>>.el-card{
  box-shadow: none;
  border: none;
  margin: 0px;
  unicode-bidi: isolate;
  word-wrap: break-word;
  font-size: 1rem;
  line-height: 1.5rem;
  padding: 0px 0px;

}
.m-chat-area>>>.el-card__body{
  padding: 8px 0px;
}
.brand-area{
  padding: 0 10px;
  display: flex;
  flex-direction: row;
  justify-content: flex-start;
  align-items: center;
  
}
.brand-class{
  font-weight: bold;
  font-size: 1.1rem;
  word-wrap: break-word;
  display: inline-block;
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
  align-items: center;
  flex: 1; 
  /* Take up remaining space */

  /* padding-right: 20px; Add some spacing between columns */
}

.chat-area {
  flex: 2;
  position: relative;
  padding-bottom: 150px !important;
  }


.cloudy-glass {
  background: rgba(255, 255, 255, 0.45);
  box-shadow: 0 4px 2px 0 rgba(31, 38, 135, 0.15);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  /* padding: 20px; */
}

.scenario,
.note {
  position: relative;
  box-sizing: border-box;
  max-height: 48.5%;
  min-height: 45%;
  height: 100%;
  padding: 10px;
  /* overflow: scroll; */
  /* flex: 1; Added */
  overflow-x: hidden; /* Hide horizontal scrollbar */
  overflow-y: scroll; /* Add vertical scrollbar */
}
.scenario{
  padding-right: 30px;
  /* scrollbar-color: #dcdfe6 #5F6367; */
  /* scrollbar-gutter: stable both-edges; */
}
.scenario::after {
  content: "» » » »";
  display: block;
  width: 10px;
  position: fixed;
  right: 6px;
  top: 40px;
  font-size: 1.5rem;
  writing-mode: vertical-rl;
  text-orientation: mixed;
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

.bar>>>.el-textarea__inner{
  width: 100%;
  border: none;
  box-shadow: none;
  border-radius: 12px;
  background: #E9EEF6 ;
  padding: 16px 12px; 
  padding-right: 60px;
  /* min-height:1.5rem; */
  font-size: 1rem;
  /* min-height: 50px; */
  /* height: 100%; */
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
  margin: 8px 4px;
  /* margin-block-start: 1em;
  margin-block-end: 1em;
  margin-inline-start: 0px;
  margin-inline-end: 0px; */
  unicode-bidi: isolate;
  word-wrap: break-word;
  font-size: 1rem;
  line-height: 1.5rem;
}

.chat-area>>>.bar.el-card{
 box-shadow: rgba(67, 71, 85, 0.27) 0px 0px 0.25em, rgba(90, 125, 188, 0.05) 0px 0.25em 1em;
}

.bar {
  
  position: absolute;
  bottom: -8px;
  left: -4px;
  right: -4px; /* Add this to make the bar span the entire width */
  z-index: 1;
}

.dialogue{
  display: flex;
  align-items: start;
  gap: 8px;
}

.avatar{
  flex-shrink: 0;
}
.user-bg{
  /* background: #abd5ff; */
   /* background: #e5ecf7; */
    background: #48566d;
   /* background: #79bcff; */
    /* background: #409EFF; */

}
.bot-bg{
  background: #f8b932;
    /* background: #90c874; */
  /* background: #67C23A; */
}

.scenario-title{
  font-size: 1.1rem;
  font-weight: bold;
  margin-bottom: 10px;
}

.submit_block{

  display: flex;
  height: 100%;
  justify-content: end;
  align-items: center;
  gap:0 12px;
}

.mobile-drawer{
  position: fixed;
  display: flex;
  width: 56px;
  height: 56px;
  align-items: center;
  justify-content: center;
  vertical-align: middle;
  right: 20px;
  bottom: 20px;
  z-index: 1000;
  box-shadow: #5F6367 0px 0px 10px 0px;
  padding: 10px;
  border: none;
  border-radius: 50%;
  background: #ffffff;
  transition: all 0.3s;
  -webkit-backface-visibility: hidden;
}
.mobile-drawer>span{
  display: flex;
  align-items: center;
  justify-content: center;
}

.scroll-bar{
  transition: all 0.3s ease-in-out;
}
.user-title{
  font-weight: 600;
  -webkit-user-select: none;
  user-select: none;
  font-size: 1rem;
  line-height: 1.5em;
  display: block;
}

.scenario::-webkit-scrollbar {
  width: 12px;
  left:-100px;
  z-index: 1000;

 
}
.scenario::-webkit-scrollbar-track {
   /* background: #1b1b1b; */
   background: #d6dfec;
    border-radius: 8px;
     margin-block: 15px;
   /* color: #000; */
   /* width: 2px; */
}
.scenario::-webkit-scrollbar-thumb {
  position: absolute;
  right: 3px;
  border-radius: 8px;
  /* border: 4px solid  #48566d; */
  border:4px solid #ffd885;
  background-clip: content-box;
  /* -webkit-box-shadow: -2px 0px 1px  #48566d ; */
  /* display: block; */
  background-color: rgb(255, 255, 255);
  /* filter: drop-shadow(5px 5px 5px rgba(0, 0, 0, 0.8)); */
  /* background: #48566d; */
  /* -webkit-box-shadow: 0 0 1px rgba(255, 255, 255, .5); */
}






.el-tour__content{
  max-width: 600px;
  width: 80% !important;
}

.bar .submit-chatbot{
  /* background: #3a3a3d; */
  background: #48566d;
  color: #ffffff;  
  vertical-align: middle;
  border-radius: 10px ;
  padding: 16px 4px;
  vertical-align: middle;
  position: absolute;
  bottom: 28px;
  right: 30px;
  z-index: 100;
}

.m-chat-area .bar .submit-chatbot{
  /* position: absolute; */
  bottom: 14px;
  right: 12px;
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

