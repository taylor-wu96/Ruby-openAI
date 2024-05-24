<template>
  <div class="submission-page">

          <el-row>
            <img src="../static/logo.png" alt="PopAi" style="width: 40px; height: 40px; margin-right: 10px;" /> 
            <div class="brand-class">
              Cohere AI | Your Personal AI Workspace
            </div> 
           
          </el-row>
    
    <el-card class="submission-card">
      <img src="../static/finish.png" alt="Finish" class="submit-img" /> 
      <div  class="submit-text"> Thank you for your submission!</div>
      <el-button size="large" color="#626aef" round class="submit-link" onclick=""> Go to post survey</el-button>
    </el-card>
  </div>
</template>

<script>
export default {

}
</script>

<style scoped>
.submission-page {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 100vh;
  gap: 20px;
}

.submission-card {
  max-width: 800px;
  width: 80%;
  padding: 40px 60px;
  display: flex !important;
  gap: 20px;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.submit-img{
  width: 100%;
  height: auto;
  display: block;
  /* margin: auto; */
  margin-bottom: 20px;
}
.submit-text{
  font-size: 20px;
  font-weight: bold;
  text-align: center;
  margin-bottom: 20px;
}
.submit-link{
  font-size: 16px;
  text-align: center;
  display: block;
  margin: 0 auto;
}

</style>
