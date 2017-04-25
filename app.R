library(shiny)
library(shinyjs)
library(shinyTime)

source("utils.R")

ui = fluidPage(

  titlePanel(div(class="jumbotron", style="padding-top: 5px; padding-bottom: 5px;",
    h2("North/Midlands Acute Stroke Clot Retrieval Screening Tool"),
    p("A screening tool to identify acute stroke patients potentially suitable for urgent transfer to Auckland Hospital for endovascular clot retrieval"),
    div(class="alert alert-danger", p("Warning: This is a development version for testing purposes ONLY")))),

  sidebarLayout(
    sidebarPanel(
      useShinyjs(),
      flipclock("onsetTimer", "Time since stroke onset"),
      hiddenNumericInput("duration", value=-99),
      width=3),

    mainPanel(
      titledPanel("Estimated stroke onset time", 
        div(class="alert alert-warning",
          p("Remember: TIME IS BRAIN. The most important determinant of outcome is time to treatment. Every minute counts.")),
        helpText("It is critically important to correctly establish the time of symptom onset. An incorrect time of onset may endanger the patient. If the patient awoke with symptoms then time of onset should be assumed to be when they fell asleep prior to waking. If the patient cannot provide any history then time of onset should be when last seen or known to be well."),
        datetimeInput("strokeOnsetTime", "Date and time of stroke symptom onset"),
        
        conditionalPanel(condition='input.duration >= 0 && input.duration < 270',
          div(class="alert alert-success",helpText("The patient is within 4.5h of symptom onset and is therefore potentially a candidate for thrombolysis +/- clot retrieval. For thrombolysis indications refer to your own hospitals guidelines and procedures. The remainder of this screening tool will refer specifically to clot retrieval."))),
        conditionalPanel(condition='input.duration >= 270 && input.duration < 360',
          div(class="alert alert-success",helpText("The patient is between 4.5h and 6h after symptom onset. The patient is no longer a candidate for thrombolysis but may still be a candidate for clot retrieval. Continue with the screening process."))),
        conditionalPanel(condition='input.duration >= 360 && input.duration < 720',
          div(class="alert alert-warning", helpText("The patient is between 6h and 12h post symptom onset. The only remaining indication for clot retrieval in this time period is a basilar occlusion. Patients with carotid or MCA occlusion are now excluded."))),
        conditionalPanel(condition="input.duration >= 720",
          div(class="alert alert-danger", helpText("The patient is more than 12h post onset and is no longer suitable for clot retrieval.")))
      ),
      
      conditionalPanel(condition='input.duration < 720 && input.duration >=0',
        titledPanel("Patient related criteria",
          checkboxInput("age",        "Is the patient >= 15y old?",width="100%"),
          checkboxInput("function",   "Is the baseline functional level at least semi-independent?",width="100%"),
          checkboxInput("BSL",        "Is the blood sugar level between 4-17mmol/L inclusive?",width="100%"),
          checkboxInput("midnorthern","Is the patient currently in a Midlands or Northern region hospital", width="100%"),
          conditionalPanel(condition='input.age && input.function && input.BSL && input.midnorthern',
            div(class="alert alert-info", 
              helpText("Stroke onset time and patient criteria are met. The patient may be a candidate for clot retrieval depending on the CT findings. Now: "),
              tags$ol(
                tags$li("Order an immediate CT brain + CTA of neck and brain."),
                tags$li("Ensure the patient has been assessed by the most appropriate local senior available doctor relevant to your hospital. This should be on-call medical registrar or physician, or local on-call neurologist")
              )
            )
          ),
          conditionalPanel(condition='(input.age && input.function && input.BSL && input.midnorthern)==false',
            div(class="alert alert-danger", 
              helpText("Current responses in this section indicate the patient does not meet screening criteria for clot retrieval. The patient may still be suitable for thrombolysis and you should refer to your local thrombolysis guidelines.")
            )
          )
        )
      ),
      
      conditionalPanel(condition='input.duration < 720 && input.age && input.function && input.BSL && input.midnorthern',
        titledPanel("CT criteria",
          div(class="alert alert-warning",
            p("CTA (CT angiography) is a mandatory pre-requisite. If your hospital does not have CTA capability the patient should be transfered to your nearest CTA capable hospital.")),
          checkboxInput("ctNoBleed",    "CT: Confirm CT shows no hemorrhage?", width="100%"),
          selectInput("ctaFinding",  "CTA: Select the best matching CTA finding:", choices = c("No Occlusion", "ICA Occlusion", "M1 or proximal M2 MCA Occlusion", "Basilar Occlusion", "Other Occlusion")),
            
          conditionalPanel(condition="(input.ctaFinding =='ICA Occlusion' || input.ctaFinding == 'M1 or proximal M2 MCA Occlusion') && input.duration < 360 && input.ctNoBleed",
            div(class="alert alert-success",
              helpText("The patient is within 6h of symptom onset with an occluded anterior circulation artery. The patient may be a candidate for transfer to Auckland Hospital for urgent endovascular clot retreival. Please do the following immediately:"),
              tags$ol(
                tags$li("Ask your radiologist to send the images immediately to Auckland PAX. The Auckland Neurologist/Neuroradiologist cannot make a treatment decision until the images have been received and viewed."),
                tags$li("Call Auckland Hospital and ask to speak to the On-Call Neurologist. Do not ask for the On-Call Neuroradiologist."),
                tags$li("If the patient is still within 4.5h of onset they may be suitable for thrombolysis in addition to clot retrieval.")
              ),
              helpText("If the patient is accepted for transfer:"),
              tags$ol(
                tags$li("Call for an urgent helicopter transfer to Auckland Hospital"),
                tags$li("Obtain consent if patient able or NOK available. Click HERE to download form (TODO)"),
                tags$li("If suitable for thrombolysis this should be initiated pre-transfer. The patient can be transferred with the infusion still running if necessary. Usual blood pressure parameters will need to be maintained.")
              )
            )
          ),
          
          conditionalPanel(condition="input.ctaFinding =='Basilar Occlusion' && input.duration < 720 && input.ctNoBleed",
            div(class="alert alert-success",
              helpText("The patient is within 12h of symptom onset with an occluded basilar artery. The patient may be a candidate for transfer to Auckland Hospital for urgent endovascular clot retreival. Please do the following immediately:"),
              tags$ol(
                tags$li("Ask your radiologist to send the images immediately to Auckland PAX. The Auckland Neurologist/Neuroradiologist cannot make a treatment decision until the images have been received and viewed."),
                tags$li("Call Auckland Hospital and ask to speak to the On-Call Neurologist. Do not ask for the On-Call Neuroradiologist."),
                tags$li("If the patient is still within 4.5h of onset they may be suitable for thrombolysis in addition to clot retrieval.")
              ),
              helpText("If the patient is accepted for transfer:"),
              tags$ol(
                tags$li("Call for an urgent helicopter transfer to Auckland Hospital"),
                tags$li("Obtain consent if patient able or NOK available. Click HERE to download form (TODO)"),
                tags$li("If suitable for thrombolysis this should be initiated pre-transfer. The patient can be transferred with the infusion still running if necessary. Usual blood pressure parameters will need to be maintained.")
              )
            )
          ),
          
          conditionalPanel(condition="((input.ctaFinding =='Basilar Occlusion' && input.duration < 720 && input.ctNoBleed) == false) && (((input.ctaFinding =='ICA Occlusion' || input.ctaFinding == 'M1 or proximal M2 MCA Occlusion') && input.duration < 360 && input.ctNoBleed)==false)",
            div(class="alert alert-warning",
              helpText("This combination of CT findings and timeframe do not meet clot retrieval criteria. If the scan shows no bleeding and the patient is still within 4.5h of symptom onset the patient may be suitable for thrombolysis - refer to local policy. Based on the responses given the patient is not suitable for transfer to Auckland Hospital and it is not necessary to discuss the case with the Auckland Hospital on-call neurologist. If uncertain discuss with your local senior physician.")
            )
          )
        )
      )
    ) # mainpanel
  )
)

server=function(session, input, output) {
  
  # TIME
  # ============================
  
  setDateTime = function(id, datetime) {
    updateDateInput2(session, paste0(id,"_date"), value=datetime)
    updateTimeInput2(session, paste0(id,"_time"), value=datetime)
  }
  
  getDateTime = function(id) {
    mydate = input[[paste0(id,"_date")]]
    mytime = strftime(input[[paste0(id,"_time")]], format="%H:%M")
    mydatetime = paste0(mydate," ",mytime)
    if (mydatetime==" ")
      return (NA)
    else
      parse_date_time(paste0(mydate," ",mytime), "Ymd HM", tz="Pacific/Auckland")
  }
  
  getDateTimeStr = function(id) {
    strftime(getDateTime(id), format="%Y-%m-%d %H:%M")
  }
  
  getElapsedTime = function(id) {
    x = getDateTime(id)
    if (!is.na(x)) {
      elapsedmins = difftime(now(tzone="Pacific/Auckland"), x, units="mins")
      return(as.integer(elapsedmins))
    }
    return(NA)
  }
  
  observeEvent(input$strokeOnsetTime_now, { setDateTime("strokeOnsetTime", now(tzone="Pacific/Auckland")) })
  
  # CLOCKS
  # =============================
  
  observe({
    input$strokeOnsetTime_date
    input$strokeOnsetTime_time
    x = getElapsedTime("strokeOnsetTime")

    if (!is.na(x)) {
      updateNumericInput(session, "duration", value=x)
      if (x > 7200)
        runjs(sprintf("clock[0].reset(); clock[0].stop();"))
      else
        runjs(sprintf("clock[0].setTime(%i); clock[0].start();", x*60))
    }
  })
}

shinyApp(ui = ui, server = server)