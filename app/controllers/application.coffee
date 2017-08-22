`import Ember from 'ember'`

ApplicationController = Ember.Controller.extend
  isReportVisible: true
  dataCount: 100
  maleNames: ['james', 'john', 'robert', 'michael', 'william', 'david', 'richard', 'charles', 'joseph', 'thomas', 'christopher', 'daniel', 'paul', 'mark', 'donald', 'george', 'kenneth', 'steven', 'edward', 'brian', 'ronald', 'anthony', 'kevin', 'jason']
  femaleNames: ['mary', 'patricia', 'linda', 'barbara', 'elizabeth', 'jennifer', 'maria', 'susan', 'margaret', 'dorothy', 'lisa', 'nancy', 'karen', 'betty', 'helen', 'sandra', 'donna', 'carol', 'ruth', 'sharon', 'michelle', 'laura', 'sarah', 'kimberly']
  lastNames: ['smith', 'johnson', 'williams', 'brown', 'jones', 'miller', 'davis', 'garcia', 'rodriguez', 'wilson', 'martinez', 'anderson', 'taylor', 'thomas', 'hernandez', 'moore', 'martin', 'jackson', 'thompson', 'white', 'lopez', 'lee', 'gonzalez', 'harris']
  locations: [
    { name: 'Auckland', longitude: '-36.867', latitude: '174.767', isHighRisk: false }
    { name: 'Wellington', longitude: '-41.287', latitude: '174.776', isHighRisk: true }
    { name: 'Christchurch', longitude: '-43.533', latitude: '172.633', isHighRisk: false }
    { name: 'Manukau', longitude: '-36.993', latitude: '174.88', isHighRisk: false }
    { name: 'Waitakere', longitude: '-36.918', latitude: '174.658', isHighRisk: true }
    { name: 'North Shore', longitude: '-36.8', latitude: '174.75', isHighRisk: true }
    { name: 'Hamilton', longitude: '-37.783', latitude: '175.283', isHighRisk: false }
    { name: 'Dunedin', longitude: '-45.874', latitude: '170.504', isHighRisk: false }
    { name: 'Tauranga', longitude: '-37.686', latitude: '176.167', isHighRisk: true }
  ]
  data: []
  margin: 20
  fullWidth: 0
  detailChartWidth: 0
  selectedFrom: new Date()
  selectedTo: new Date()
  alarmThreshold: 3
  quantitiesOfData: [10, 100, 500, 1000, 10000, 100000, 1000000]

  init: ->
    @genData()
    @setVisibleSubChart('Gender')

  genData: ->
    data = []
    now = new Date()
    to = new Date(now)
    from = new Date(now.setFullYear(now.getFullYear() - 1))
    @set('to', to)
    @set('from', from)

    @genDoctors()
    @genPatients()
    for i in [1..@get('dataCount')]
      patient = @getRandPatient()
      data.pushObject
        patient: patient
        diagnosisDate: @getRandDate()
    @set('data', data)

  genDoctors: ->
    doctors = []
    for i in [1..@get('dataCount') / 20]
      gender = @getRandGender()
      doctors.pushObject
        id: i
        name: @getRandName(gender)
        gender: gender
        location: @getRandLocation()
    @set('doctors', doctors)

  genPatients: ->
    patients = []
    for i in [1..@get('dataCount') / 5]
      gender = @getRandGender()
      patients.pushObject
        id: i
        name: @getRandName(gender)
        gender: gender
        age: @getRandAge()
        ethnicity: @getRandEthnicity()
        hasFluShot: @getRandBool()
        doctor: @getRandDoctor()
    @set('patients', patients)

  getRandDoctor: ->
    @getRand(@get('doctors'))

  getRandPatient: ->
    @getRand(@get('patients'))

  getRandAge: ->
    @getRand([0..100])

  getRandEthnicity: ->
    @getRand(['european', 'maori', 'asian', 'african', 'pacific people', 'middle eastern'])

  getRandDate: ->
    from = @get('from')
    to = @get('to')
    new Date(from.getTime() + Math.random() * (to.getTime() - from.getTime()))

  getRandGender: ->
    @getRand(['female', 'male'])

  getRandName: (gender)->
    firstName = @getRand(if gender == 'female' then @get('femaleNames') else @get('maleNames'))
    lastName = @getRand(@get('lastNames'))
    "#{ firstName } #{ lastName }"

  getRandLocation: ->
    @getRand(@get('locations'))

  getRandBool: ->
    @getRand([true, false])

  getRand: (arr)->
    arr[Math.floor(Math.random() * arr.length)]

  timeVsCasesOfTheFlu: (->
    date = new Date(@get('to'))
    from = @get('from')
    bins = {}
    while date > from
      @roundDateToNearestDay(date)
      nextDate = date.getDate() - 1
      bins[new Date(date)] = 0
      date = new Date(date.setDate(nextDate))

    @get('data').forEach (row)=>
      index = new Date(@roundDateToNearestDay(new Date(row.diagnosisDate)))
      count = bins[index]
      bins[index] = count + 1 if count?

    data = []
    for k, v of bins
      data.push({x: k, y: v})

    data
  ).property('data', 'to', 'from')

  timeVsCasesOfTheFluDetail: (->
    selectedFrom = @get('selectedFrom')
    selectedTo = @get('selectedTo')
    @get('timeVsCasesOfTheFlu').filter (row)->
      x = new Date(row.x)
      x >= selectedFrom and x <= selectedTo
  ).property('timeVsCasesOfTheFlu', 'selectedTo', 'selectedFrom')

  genderVsCasesOfTheFlu: (->
    femaleCasesOfFlu = 0
    maleCasesOfFlu = 0
    selectedTo = this.get('selectedTo')
    selectedFrom = this.get('selectedFrom')

    @get('data').forEach (row)->
      diagnosisDate = new Date(row.diagnosisDate)
      if diagnosisDate >= selectedFrom and diagnosisDate <= selectedTo
        if row.patient.gender == 'male'
          maleCasesOfFlu += 1
        else
          femaleCasesOfFlu += 1

    [{x: 'Male', y: maleCasesOfFlu}, {x: 'Female', y: femaleCasesOfFlu}]
  ).property('data', 'selectedTo', 'selectedFrom')

  totalInSelection: ( ->
    genderVsCasesOfTheFlu = @get('genderVsCasesOfTheFlu')
    genderVsCasesOfTheFlu[0].y + genderVsCasesOfTheFlu[1].y
  ).property('genderVsCasesOfTheFlu')

  ageVsCasesOfTheFlu: (->
    under15 = 0
    age16To30 = 0
    age31To45 = 0
    age46To60 = 0
    age61To75 = 0
    over76 = 0
    selectedTo = this.get('selectedTo')
    selectedFrom = this.get('selectedFrom')

    @get('data').forEach (row)=>
      diagnosisDate = new Date(row.diagnosisDate)
      if diagnosisDate >= selectedFrom and diagnosisDate <= selectedTo
        switch
          when row.patient.age <= 15 then under15 += 1
          when row.patient.age >=16 and row.patient.age <= 30 then age16To30 += 1
          when row.patient.age >=31 and row.patient.age <= 45 then age31To45 += 1
          when row.patient.age >=46 and row.patient.age <= 60 then age46To60 += 1
          when row.patient.age >=61 and row.patient.age <= 75 then age61To75 += 1
          else over76 += 1
    [
      {x: 'Under 15', y: under15}
      {x: '16 - 30', y: age16To30}
      {x: '31 - 45', y: age31To45}
      {x: '46 - 60', y: age46To60}
      {x: '61 - 75', y: age61To75}
      {x: 'Over 76', y: over76}
    ]
  ).property('data', 'selectedTo', 'selectedFrom')

  ethnicityVsCasesOfTheFlu: (->
    european = 0
    maori = 0
    asian = 0
    african = 0
    pacificPeople = 0
    middleEastern = 0
    selectedTo = this.get('selectedTo')
    selectedFrom = this.get('selectedFrom')

    @get('data').forEach (row)=>
      diagnosisDate = new Date(row.diagnosisDate)
      if diagnosisDate >= selectedFrom and diagnosisDate <= selectedTo
        switch row.patient.ethnicity
          when 'maori' then maori += 1
          when 'asian' then asian += 1
          when 'african' then african += 1
          when 'pacific people' then pacificPeople += 1
          when 'middle eastern' then middleEastern += 1
          else european += 1
    [
      {x: 'European', y: european}
      {x: 'Maori', y: maori}
      {x: 'Asian', y: asian}
      {x: 'African', y: african}
      {x: 'Pacific People', y: pacificPeople}
      {x: 'Middle Eastern', y: middleEastern}
    ]
  ).property('data', 'selectedTo', 'selectedFrom')

  patientsVsFluOccurrences: ( ->
    data = {}
    selectedTo = this.get('selectedTo')
    selectedFrom = this.get('selectedFrom')

    @get('data').forEach (row)->
      diagnosisDate = new Date(row.diagnosisDate)
      if diagnosisDate >= selectedFrom and diagnosisDate <= selectedTo
        name = row.patient.name
        data[name] = 0 unless data[name]?
        data[name] += 1
    data
  ).property('data', 'selectedTo', 'selectedFrom')

  fluOccurrences: ( ->
    one = 0
    two = 0
    three = 0
    four = 0
    five = 0
    six = 0
    more = 0

    for name, count of @get('patientsVsFluOccurrences')
      switch count
        when 1 then one += 1
        when 2 then two += 1
        when 3 then three += 1
        when 4 then four += 1
        when 5 then five += 1
        when 6 then six += 1
        else
          more += 1
    [
      {x: 'One', y: one}
      {x: 'Two', y: two}
      {x: 'Three', y: three}
      {x: 'Four', y: four}
      {x: 'Five', y: five}
      {x: 'Six', y: six}
      {x: 'More', y: more}
    ]
  ).property('patientsVsFluOccurrences')

  fluAlarms: ( ->
    alarmThreshold = @get('alarmThreshold')
    alarms = []

    for name, count of @get('patientsVsFluOccurrences')
      if count >= alarmThreshold
        alarms.push({ name: name, count: count })

    alarms
  ).property('patientsVsFluOccurrences')

  min: (->
    d3.min(@get('timeVsCasesOfTheFluDetail'), (row)-> row.y)
  ).property('timeVsCasesOfTheFluDetail')

  average: (->
    mean = d3.mean(@get('timeVsCasesOfTheFluDetail'), (row)-> row.y)
    if mean? then mean.toFixed(3) else 0.0
  ).property('timeVsCasesOfTheFluDetail')

  max: (->
    d3.max(@get('timeVsCasesOfTheFluDetail'), (row)-> row.y)
  ).property('timeVsCasesOfTheFluDetail')

  variance: (->
    variance = d3.variance(@get('timeVsCasesOfTheFluDetail'), (row)-> row.y)
    if variance? then variance.toFixed(3) else 0.0
  ).property('timeVsCasesOfTheFluDetail')

  roundDateToNearestDay: (date)->
    date.setHours(date.getHours() + Math.round(date.getMinutes()/60))
    date.setDate(date.getDate() + Math.round(date.getHours()/24))
    date.setHours(0)
    date.setMinutes(0)
    date.setSeconds(0)

  setVisibleSubChart: (chartTitle)->
    @set('visibleSubChartTitle', chartTitle)
    @set('isFluVsGenderVisible', false)
    @set('isFluVsAgeGroupVisible', false)
    @set('isFluVsOccurrencesVisible', false)
    @set('isFluVsAlarmsVisible', false)
    @set('isFluVsEthnicityVisible', false)
    @set("isFluVs#{chartTitle.replace(' ', '')}Visible", true)

  actions:
    setDataCount: (dataCount)->
      @set('dataCount', dataCount)
      false

    regenerateData: ->
      @genData()
      false

    showReport: ->
      @set('isReportVisible', true)
      false

    showData: ->
      @set('isReportVisible', false)
      false

    showFluVsGender: ->
      @setVisibleSubChart('Gender')
      false

    showFluVsAgeGroup: ->
      @setVisibleSubChart('Age Group')
      false

    showFluVsOccurrences: ->
      @setVisibleSubChart('Occurrences')
      false

    showFluVsEthnicity: ->
      @setVisibleSubChart('Ethnicity')
      false

    showFluVsAlarms: ->
      @setVisibleSubChart('Alarms')
      false

`export default ApplicationController`
