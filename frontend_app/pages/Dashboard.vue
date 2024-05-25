<template>
  <div id="app">
    <el-container style="height: 100vh;">
      <el-container class="dashboard" style="height:100%">
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
                <div class="scenario-scroll">
                  <div class="scenario-title">
                    Your Task
                  </div>
                  <div  v-html="scenarioText">
                  </div>
                </div>
              </el-card>
              <el-card ref="noteRef" class="note">
                <el-scrollbar always max-height="100%" height="100%">
                  <div class="scenario-title">
                  Your Answer
                  <el-text size="small" tag="i"> Enter the all of task in the following input field </el-text>
                </div>
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
                <div class="note_panel">
                  <div class="text-area_info">
                    <div><el-icon  size="small"><Finished /></el-icon> Word: {{ textAreaWordCount }} ( {{minWords}}~{{maxWords}} ) </div>
                    <div> <el-icon size="small"><Timer /></el-icon> Time Left: <span v-html="timeSeconds"></span> </div>
                  </div>
                  <el-form ref="submitTaskRef"  label-width="auto" >
                      <div class="submit_block">
                        <el-form-item label="I have finished">
                          <!-- active-icon="Check" inactive-icon="Close" -->
                            <el-switch v-model="hasFinishTask" :before-change="checkTaskFinish"  />
                          </el-form-item>
                          <el-form-item>
                            <el-button  type="info" :disabled="!hasFinishTask" round @click="onSubmitTask">Submit</el-button>
                          </el-form-item>
                      </div>
                  </el-form>
                  
                </div>

                <!-- <p>{{highlightedText}}</p> -->

                </el-scrollbar>
                

            </el-card>
            </el-col>
            <el-col v-if="!mobileDrawer" ref="chatBotRef"  :xs="24" :sm="24" :md="24" :lg="11" :xl="11" class="chat-area cloudy-glass invisible">
              <!-- Chat messages will go here -->
              <div style="padding:5px 4px">
                  <el-popover
                    placement="top-start"
                    title="Task AI"
                    :width="400"
                    trigger="hover"
                    content="Task AI is a chatbot powered by GPT-4o. It can help you with various tasks. especially for text-related tasks."
                  >
                    <template #reference>
                       <el-text  size="large" tag="b" class="chat-title"> Task AI
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
                        <!-- style="white-space: pre-line"  -->
                        <div :id="'user_question_' + message.id" v-html="message.text"></div>
                      </div>

                    </div>
                    <div  class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar bot-bg"   icon="ChatLineRound" />
                      <div>
                        <div class="user-title"  :id="'ai_feedback_tag_' + message.id" >
                          Chatbot
                        </div>
                        <!-- <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag> -->
                        <!-- style="white-space: pre-line"  -->
                        <div  :id="'ai_feedback_' + message.id" style="word-wrap: break-word; white-space: pre-wrap; line-height:1.1" v-html="message.text"></div>
                        <!-- <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip> -->
                        <!-- <span v-if="isLastChatbotMessage(message)">
                          <el-button :disabled="MIN_TEMP>=currentTemp" @click="resentMessage(false)" size="small" type="info" plain round>
                           Give me more various idea!
                          </el-button>
                          <el-button :disabled="MAX_TEMP<=currentTemp" @click="resentMessage(true)" size="small" type="info" plain round>
                            Give me more cautious idea!
                          </el-button>

                        </span>                      -->
                      </div>
                    </div>
                  </el-card>
                </div>
              </el-scrollbar>
              <el-card ref="chatInputRef" class="bar">
                <el-input
                  type="textarea"
                  :autosize="{ minRows: 1 , maxRows: 6}"
                  id="PromptArea"
                  class="prompt_input"
                  name="PromptArea"
                  v-model="userInput"
                  placeholder="Type your message here..."
                  resize="none"
                  @input="handlePromptInput($event, userInput)"
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
                <el-button class="submit-chatbot" :disabled="messageSending" :loading="messageSending" @click="sendMessage">      
                      <Promotion v-show="!messageSending"  style="width:24px; vertical-align:middle;  padding:0;" />
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
        <el-drawer class="inner-drawer" @open="scrollToBottom();" v-model="drawer" size="80%" title="Task AI" >
           <div class="m-chat-area">
              <el-scrollbar class="scroll-bar" ref="scrollContainer">
                <div v-for="message in messages" :key="message.id" class="message">
                  <el-card>
                    <div class="dialogue"  v-if="message.sender === 'user'" :id="'user_question_block_' + message.id" @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar user-bg" icon="UserFilled" />
                      <div>
                         <div class="user-title"  :id="'user_question_tag_' + message.id">
                          You
                        </div>
                        <!-- <el-tag size="small" :id="'user_question_tag_' + message.id">You</el-tag> -->
                        <!-- style="white-space: pre-line"  -->
                        <div :id="'user_question_' + message.id" v-html="message.text"></div>
                      </div>

                    </div>
                    <div  class="dialogue" v-else :id="'ai_feedback_block_' + message.id"   @mouseup="handleMouseUp" @copy="handleCopy">
                      <el-avatar :size="28" class="avatar bot-bg"   icon="ChatLineRound" />
                      <div>
                        <div class="user-title"  :id="'ai_feedback_tag_' + message.id" >
                          Chatbot
                        </div>
                        <!-- <el-tag  :id="'ai_feedback_tag_' + message.id" size="small" type="success">Chatbot</el-tag> -->
                        <!-- style="white-space: pre-line"  -->
                        <div  :id="'ai_feedback_' + message.id" style="word-wrap: break-word; white-space: pre-wrap; line-height:1.1" v-html="message.text"></div>
                        <!-- <el-tooltip :id="'icon_' + message.id" placement="bottom">
                          <template  #content> Copy </template>
                          <el-button :id="'button_' + message.id" size="small" type="info" plain  @click="handleCopiedButton" round >
                          <el-icon :id="'button_' + message.id" ><CopyDocument :id="'button_' + message.id" /> </el-icon>
                        </el-button>
                        </el-tooltip> -->
                        <!-- <span v-if="isLastChatbotMessage(message)">
                          <el-button :disabled="MIN_TEMP>=currentTemp" @click="resentMessage(false)" size="small" type="info" plain round>
                           Give me more various idea!
                          </el-button>
                          <el-button :disabled="MAX_TEMP<=currentTemp" @click="resentMessage(true)" size="small" type="info" plain round>
                            Give me more cautious idea!
                          </el-button>

                        </span>                      -->
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
                  @input="handlePromptInput($event, userInput)"
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
                <el-button class="submit-chatbot" :disabled="messageSending" :loading="messageSending" @click="sendMessage">      
                      <Promotion v-show="!messageSending"  style="width:24px; vertical-align:middle;  padding:0;" />
                </el-button>
              </el-card>
            </div>
        </el-drawer>

        <!-- Tour Code -->

        <el-tour :show-close="false" @finish="tourFinished" :mask="{ color: '#000000df', }" v-model="open" type="default" >
          <el-tour-step title="Introduction" :content-style="{ maxWidth: '800px', width:'80%', padding:'40px'}">
            <h2>About the Task: </h2>
            <br/>
            <div style="font-size: 1.125rem;line-height: 150%;font-weight: 400;">In this website You have to finish a task in a given scenario. We hope to leverage your ideas to help us come up with better plans within a limited time. <b>To reward the best participants, we will select the top three submissions based on completeness, originality, and clarity.</b> These top participants will receive additional rewards, which will be distributed through Prolific and communicated via private messages.</div>
            <br/>
            <div style="font-size: 1.125rem;line-height: 150%;font-weight: 400;">
              <ul style="padding: 10px;">
                <li>
                  During the task, we encourage you to use your existing knowledge and  the AI assistant we provide. 
                </li>
                <li>
                  Avoid searching for information on other websites.The accuracy of the facts is not our primary concern. 
                </li>
                <li>
                  Instead, we are interested in whether your responses sufficiently reflect your own original ideas.
                </li>
              </ul>
            </div>
            <br/>
            <div style="font-size: 1.125rem;line-height: 150%;font-weight: 400;">
              Below, we will provide a step-by-step introduction to the website's UI to help you quickly navigate the system.
            </div>
          </el-tour-step>
         
          <el-tour-step
            :target="scenarioRef?.$el"
            title="Scenario"
            description="Here, you will see the details of the scenario for the task. You should finish the requirements of the scenario to finish the task. You might need to scroll downto see the full details."
          />
          <el-tour-step
            :target="noteRef?.$el"
            title="Your Answer"
            description="You can keep all of your notes and answer here before submission. You can see the word count below the text area. We expect you to complete your responses in 10 minutes. You can track your elapsed time in the response area. If you exceed 10 minutes, we will give you a notice message."

          />
               <!-- placement="left-start" -->
          <el-tour-step
            :placement="!mobileDrawer?'left':'top-start'"
            :target="chatBotRef?.$el"
            title="Task AI"
            description="Task AI is an AI chatbot service. We have used the current best AI tools, and trained it to the travel context you are working on.  It can help you generate or refine your ideas and words. You might need to scroll down to see the latest message."
          />

          <el-tour-step
            :target="chatInputRef?.$el"
            title="Question to AI"
            description="Type the question you want to ask the AI assistant here, and then click the send button to await a response."
          />
          <el-tour-step
            :target="submitTaskRef?.$el"
            title="Submit Task"
            description="After you finish the task, please click the toggle to confirm that you have finished the answer, and then you can click the submit button."
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
import {marked} from "marked";
import { ref, watch, nextTick } from 'vue';
import { onMounted, onUnmounted } from 'vue';
import { useRoute , useRouter } from 'vue-router';
import { watchEffect } from 'vue';
import { ElMessage,ElNotification  } from 'element-plus'
import { useStore } from 'vuex'


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
    const router = useRouter();
    const user_id = ref('anonymous');
    let promptStartTime=0
    let promptEndTime=0
    let wordEditingCount=0
    let wordDeletingCount=0
    let characterRevisionCount=0
    let previousCharacterCount=0
    let timeId

    // Timer
    const TIME_GAP =10;
    const MISSION_TIME = 20;
    const timeSeconds = ref("10:00");

    let missionTimeStamp = 0;


    // streaming variables
    const messageSending = ref(false);

    // shared store variables

    const store = useStore()
    const updateSharedVariable = (obj) => {
      store.commit('updateSharedVariable', obj)
    }

   

    const currentTemp=ref(Constants.DEFAULTS_TEMP)
    const MAX_TEMP=Constants.MAX_TEMP
    const MIN_TEMP=Constants.MIN_TEMP
    let focus_leave=0

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
      user_id.value = route.query[Constants.URL_USER_PARAMS] || 'anonymous';
      if(user_id.value === 'anonymous'){
        router.push({ path: '/missing' })
      
      }
      updateSharedVariable({'user_id': user_id.value});
      localData['user_id'] = user_id.value
      if (!localStorage.getItem(user_id.value)) {
        localStorage.setItem(user_id.value, JSON.stringify(localData));
        // console.log('Local Data:', localData);
      } else {
        const data = await localStorage.getItem(user_id.value);
        localData = JSON.parse(data);
        // console.log('Local Data:', localData);
        textArea.value = localData['storage_notes']||'';
        if(textArea.value){
          previousCharacterCount = textArea.value.length;
          textAreaWordCount.value = textArea.value.trim().split(/\s+|\n+/).length;
        }
        if(localData['tour']===false){
          open.value = localData['tour'];
          timeId = setInterval(setTimer, TIME_GAP*1000);
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
      // remove the interval in timer
      clearInterval(timeId);
    });


    // Tour 
    const tourFinished = () => {
      // console.log('Tour Finished');
      if(localData['tour']!==false){
          timeId = setInterval(setTimer, TIME_GAP*1000);
        }
      // setInterval(setTimer, TIME_GAP*1000);
      localData['tour']=false;
      localStorage.setItem(user_id.value, JSON.stringify(localData));
    };


    // Timer
    function setTimer() {
    
      if(missionTimeStamp===0){
        missionTimeStamp=new Date().getTime()
      };
      let currentTime = new Date().getTime();
      // console.log('Current Time:',missionTimeStamp,"  : ", currentTime);

      let missionTimeLeft=MISSION_TIME-Math.floor((currentTime-missionTimeStamp)/1000);
      if( missionTimeLeft <= 0 && missionTimeLeft >= -TIME_GAP){
        ElNotification({
          title: 'Reminder',
          message: `You have spent ${Math.floor(MISSION_TIME/60)} minutes on the task.`,
          type: 'info',
        })
        // timeSeconds.value = 'You have spent 10 minutes'
        timeSeconds.value = `<span style="color: rgb(190, 79, 79);"> You have spent ${Math.floor(MISSION_TIME/60)} minutes</span>`;
      }
      else if(missionTimeLeft >0){
        timeSeconds.value = pad(Math.floor(missionTimeLeft / 60)) +" : "+ pad(missionTimeLeft % 60);
      }
    }

    function pad(val) {
      let valString = val + "";
      if (valString.length < 2) {
        return "0" + valString;
      } else {
        return valString;
      }
    }


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
            text: marked(chat.response),
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

    const sendMessage = async() => {
      if (userInput.value.trim()) {
        // messages.value.push({ id: Date.now(), text: userInput.value, sender: 'user' });
        // Here you'd typically send the message to your backend for processing
        createMessage(marked(userInput.value),'user');

        // API for none streaming version
        // getResponse(userInput.value);
        // API for streaming version
        await streamingResponse();

        userInput.value = ''; // Clear input after sending
        // console.log('User Prompt Time:', (promptEndTime-promptStartTime)/1000);
        promptStartTime=0;
        promptEndTime=0;
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
        // console.log('Response Behavior', data);
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
      // console.log('Task:', data.task_name);
      if(data.final_submission){
        router.push({ path: '/submitted' })
      }
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
        api_url = `/submit-task?user_id=${user_id.value}`
        ;
      } 
      const { data } = await axios.post(api_url,{task_description: textArea.value});
      ElNotification({
          title: 'Finish',
          message: "You have Successfully Submit the task!",
          type: 'success',
      })
      updateSharedVariable({submitted: true});
      router.push({ path: '/submitted' })
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
    } catch (error) {
      console.error('Failed to update IP:', error);
    }

  }

  let controller = null; 
  const streamingResponse = async () => {
    messageSending.value = true;
    
    let streaming_message = '';
    let api_url = "/openAI-streaming";
    if(user_id.value !== 'anonymous'){
      api_url = `/openAI-streaming?user_id=${user_id.value}`
      ;
    } 
    controller = new AbortController();
    const signal = controller.signal;
    try {
      const receivedMessage ={
        id: Date.now(),
        text: '',
        sender: 'assistant',
      };
      messages.value.push(receivedMessage);


      const response = await fetch(api_url,
      {
        method: "POST",
        headers: {
        "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message_content: userInput.value,
          system_temp: currentTemp.value,
          role: "user",
        }),
        signal,
      });
      userInput.value = '';
      // disabled the sender button
      const reader = response.body.getReader();
      const decoder = new TextDecoder("utf-8");

      while(true){
        const {done, value} = await reader.read();
        if(done){
          break;
        }
        const chunk = decoder.decode(value);

        const lines = chunk.split("\n");
        // console.log('Streaming Lines:', lines);
        const parsedLines = lines.filter((line) => line.trim() !== ''  && !line.includes("[DONE]"))
                                .map((line)=>line.replace(/^data: /, "").trim())
                                .map((line) => JSON.parse(line));
        // console.log('Streaming Response:', parsedLines);
        for ( const parsedLine of parsedLines){
          const {choices} = parsedLine;
          const { delta } = choices[0];
          const { content } = delta;
          if(content){
            streaming_message += content;
            messages.value[messages.value.length - 1]["text"] = marked(streaming_message);
          }         
          // console.log('Store to messages:', messages.value[messages.value.length - 1]);
          // console.log('Streaming Response:', output_response);
          // createMessage(marked(parsedLine.response), "assistant");
        }

      }

      // console.log('Streaming Response:', data);
    } catch (error) {
      if(signal.aborted){
        console.error('Request Aborted:', error);
      }else{
        console.error('Failed to Streaming:', error);
      }
    }finally{
      controller = null;
      messageSending.value = false;
      // send API to backend
      await storeMessage(streaming_message,'assistant');
    }
  }

  const storeMessage = async (message,role) => {
    try{
      const postData = {
        message_content: message,
        system_temp: currentTemp.value,
        role: role,
      };
      console.log('Post Data:', postData);
        let api_url = "/message";
        if(user_id.value !== 'anonymous'){
          api_url = `/message?user_id=${user_id.value}`;
        } 
      const { data } = await axios.post(api_url, postData);
      console.log('Store Message:', data);

    }catch(error){
      console.error('Failed to store message:', error);
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
        role: "user",
      };
        let api_url = "/openai";
        if(user_id.value !== 'anonymous'){
          api_url = `/openai?user_id=${user_id.value}`;
        } 
      const { data } = await axios.post(api_url, postData);
      // console.log(data);
      createMessage(marked(data.response), "assistant");
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
       
        if(previousCharacterCount ===inputValue.length-1 || previousCharacterCount ===inputValue.length+1){
          characterRevisionCount+=1;
          // console.log('User Character Modifying :', characterRevisionCount);
        }
        previousCharacterCount = textArea.value.length;
        textArea.value = inputValue;
        localData['storage_notes']=inputValue
        localStorage.setItem(user_id.value, JSON.stringify(localData));
        // localStorage.setItem('storage_notes', inputValue);
        // console.log('Input Value:', inputValue, inputValue.split(/\s+|\n+/).length);
        const words = inputValue.trim().split(/\s+|\n+/);
        let previousWordCount = textAreaWordCount.value;
        // If the trimmed inputValue is empty, set word count to 0, else to the length of the words array
        textAreaWordCount.value = inputValue.trim() ? words.length : 0;
        if (previousWordCount !== textAreaWordCount.value) {
          // console.log('Word Add/Remove:', inputValue);
          sendBehavior({
            id: Date.now(),
            content: inputValue,
            type: 'Word Add/Remove',
            target_object: 'NoteArea',
            log_time: new Date().toISOString(),
          })  
        }
        if(previousWordCount === textAreaWordCount.value-1){
         
          wordEditingCount+=1;
          // console.log('User Manual Modifying :', wordEditingCount);

        }else if(previousWordCount > textAreaWordCount.value){
          wordDeletingCount+=previousWordCount - textAreaWordCount.value;
          // console.log('User Manual Deleting :', wordDeletingCount);
        }
        // else if(previousWordCount === textAreaWordCount.value){
        //   characterRevisionCount+=1;
        //   console.log('User Character Modifying :', characterRevisionCount);
        // }

      }
    };
    const handlePromptInput = (e, value) => {
      let inputValue;
      if (e && e.target) {
        inputValue = e.target.value;
      } else {
        inputValue = value;
      }
      if(inputValue!==undefined){
        if(promptStartTime===0){
          promptStartTime=new Date().getTime();
        }
        else{
          promptEndTime=new Date().getTime();
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
            target_object: 'NoteArea',
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
      // console.log('Response element:', aiResponseElement);
      const copiedText = aiResponseElement.textContent;
      // console.log('Copied Text:', copiedText);

      // console.log('Copied Button');
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
      // console.log(e.clipboardData.getData('text/plain'));
      // console.log('Copied Text:', window.getSelection().toString());
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
      // console.log('Pasted Text:', pastedText);
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
          // console.log('Selected Text:', selectedText);
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
      // console.log('Mouse Up');

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
        // console.log('Highlight Text:', selectedText);
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

    const endFocusTime = (e) => {
      focusTimeEnd = new Date().getTime();
      // console.log('Time Spent:', (focusTimeEnd - focusTimeStart) / 1000);
      highlightedText.value='Focus Time Spent:'+ (focusTimeEnd - focusTimeStart) / 1000
      const targetElementName = e.target.name||e.target.id||e.target.nodeName;
      sendBehavior({
        id: Date.now(),
        content: (focusTimeEnd - focusTimeStart) / 1000,
        type: 'focus_time',
        target_object: targetElementName,
        log_time: new Date(focusTimeEnd).toISOString(),
      })
      focusTimeStart = 0;
    };

    document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      // console.log('User is focused on the page');
      if(focus_leave===0){
        sendBehavior({
            id: Date.now(),
            content: 'User is open the page on' + Date.now().toString(),
            type: 'Initial',
            target_object: 'page',
            log_time: new Date().toISOString(),
       })  
      }
      else{
         sendBehavior({
            id: Date.now(),
            content: (focus_leave-new Date().getTime())/1000,
            type: 'Leaving Time',
            target_object: 'page',
            log_time: new Date().toISOString(),
       })  
      }
      // Perform actions when the page is in focus

       highlightedText.value='User is focused on the page'

    } else {
      // console.log('User has left the page');
      // Perform actions when the page is not in focus
      sendBehavior({
            id: Date.now(),
            content: (focus_leave-new Date().getTime())/1000,
            type: 'Stay Time',
            target_object: 'page',
            log_time: new Date().toISOString(),
      })  
    }
    focus_leave=new Date().getTime();
    });
    
    window.addEventListener('resize', () => {
      if(window.innerWidth<992){
        // console.log("Window width:", window.innerWidth); 
        // console.log('Mobile View');
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
      createMessage(marked(RESENT_PROMPT),'user')
      getResponse(RESENT_PROMPT)
    };


    // Listen the ipAddress
    const getIPFromAmazon=async()=> {
      fetch("https://checkip.amazonaws.com/").then(res => res.text()).then(data => {
        ipAddress.value = data;
        // console.log('IP: '+data)
        })
    }

    return { messages,
      timeSeconds,
      messageSending,
      minWords,
      maxWords, 
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
      handlePromptInput,
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
  padding: 0;
  margin: 0;
  -webkit-font-smoothing: antialiased;
}

.chat-area,
.task-area {
  margin: 10px;
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
  display: flex !important; 
  flex-direction: column; /* Added */
  align-items: center;
  flex: 1;  
  /* gap: 10px; */

  /* padding-right: 20px; Add some spacing between columns */
}

.chat-area {
  /* flex: 2; */
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
  /* flex: 1; */
  flex-grow: 1;
  height: 50%;
  padding: 12px;
  width: 100%;

}
.scenario>>>.el-card__body{
  overflow: hidden;
  height: 100%;
  padding: 0;
}
.scenario-scroll{
  padding: 0;
  height: 100%;
  overflow-y: scroll; 
  padding-bottom:60px ;
}
/* scenario-scroll */
.note{
  overflow-y: scroll; 
}


.scenario{
  /* padding-right: 30px; */
  -webkit-user-select: none; /* Safari */
  -ms-user-select: none; /* IE 10 and IE 11 */
  user-select: none; /* Standard syntax */
  overflow: hidden;
  padding: 10px 20px;
}
/* .scenario::after {
  content: "» » » »";
  display: block;
  width: 10px;
  position: fixed;
  right: 6px;
  top: 40px;
  font-size: 1.5rem;
  writing-mode: vertical-rl;
  text-orientation: mixed;
} */
.scenario::before{
  content: "";
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  height: 80px;
  background: linear-gradient(rgba(179, 179, 179, 0.001), rgb(255, 255, 255)) ;
  position: absolute;
  z-index: 1;
}
.note_panel{
  display: flex;
  /* align-items: center; */
  margin-top: 8px;
  justify-content: space-between;
}

.text-area_info{
  display: flex;
  flex-direction: column;
  align-items: baseline;
  justify-items: start;
  text-align: left;

}
.text-area_info>div{
  font-size: 0.8rem;
  display: block;
  line-height: 1.6;
  color: #353535;
  /* padding: 2px 0; */
  margin: 0;
  display: flex;
  align-items: center;
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
  flex-direction:column ;
  /* justify-content: end; */
  align-items: flex-end;
}
.submit_block>>>.el-form-item{
  /* padding: 0; */
  margin: 0;
  margin-bottom:4px;
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






.el-tour .el-tour__content{
  max-width: 800px;
  width: 80% ;
  padding: 100px;
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

.submit-chatbot >>>.el-icon.is-loading{
  width:24px; 
  height: auto;
  vertical-align:middle;  
  padding:0;
  font-size: 1.1rem;
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

