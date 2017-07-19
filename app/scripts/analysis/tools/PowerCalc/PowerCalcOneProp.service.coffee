'use strict'

BaseService = require 'scripts/BaseClasses/BaseService.coffee'

###
  @name: app_analysis_powercalc_oneProp
  @type: service
  @desc: Performs one sample proportion test
###


module.exports = class PowerCalcOneProp extends BaseService
  @inject 'app_analysis_powerCalc_msgService',
    '$timeout'

   initialize: ->
    @distanceFromMean = 5
    @SIGNIFICANT = 5
    @populations = null
    @distribution = require 'distributome'
    @msgService = @app_analysis_powerCalc_msgService
    @name = 'Test of One Proportion'

    #variables needed globally
    @onePropP = 0.5
    @onePropP0 = 0.5
    @onePropPMax = 1
    @onePropN = 50
    @onePropNMax = 100
    @onePropPower = 0
    @onePropAlpha = 0.010
    @onePropT = 0
    @onePropPvalue = 0
    @compAgents = ''
    @mode = 'One Sided'
    @modes = ['One Sided', 'Two Sided']


    #data to observe
    @parameters =
      p: @onePropP
      p0: @onePropP0
      pMax: @onePropPMax
      n: @onePropN
      nMax: @onePropNMax
      power: @onePropPower
      t: @onePropT
      pvl: @onePropPvalue
      comp: @compAgents
      mode: @mode

    @onePropUpdate()

  saveData: (data) ->
    # @populations = data.populations
    # lab = data.chosenlab
    # if (lab is "none") or (lab is null)
    #   @compAgents = data.chosenCol
    # else
    #   @compAgents = data.chosenVar
    # @onePropReceiveData()
    return

  setAlpha: (alphaIn) ->
    @onePropAlpha = alphaIn
    @onePropUpdate()
    return

  getName: () ->
    return @name

  getParams: () ->
    @parameters =
      p: @onePropP
      p0: @onePropP0
      pMax: @onePropPMax
      n: @onePropN
      nMax: @onePropNMax
      power: @onePropPower
      t: @onePropT
      pvl: @onePropPvalue
      comp: @compAgents
      mode: @mode

  setParams: (newParams) ->
    @onePropP = newParams.p
    @onePropP0 = newParams.p0
    @onePropN = newParams.n
    @mode = newParams.mode
    @onePropUpdate()
    return

  savePower: (newParams) ->
    @onePropPower = newParams.power
    @mode = newParams.mode
    @onePropPowerTon()
    return

  reset: () ->
    @onePropP = 0.5
    @onePropP0 = 0.5
    @onePropPMax = 1
    @onePropN = 50
    @onePropNMax = 100
    @onePropPower = 0
    @onePropAlpha = 0.010
    @onePropT = 0
    @onePropPvalue = 0
    @mode = 'Two Sided'
    @compAgents = ''
    @onePropUpdate()
    return

  # onePropReceiveData: () ->
  #   item = Object.keys(@populations)[0]
  #   @onePropN = @populations[item].length
  #   # TODO: additional variables need to be calculated
  #   @onePropCheckRange()
  #   @onePropUpdate()
  #   return

  onePropCheckRange:() ->
    @onePropNMax = Math.max(@onePropN, @onePropNMax)
    @onePropPMax = Math.max(@onePropP, @onePropP0, @onePropPMax)
    return

  onePropUpdate: () ->
    z=(@onePropP-@onePropP0) / Math.sqrt(@onePropP*(1-@onePropP)/@onePropN)
    if @mode is "Two Sided"
      @onePropPower=@distribution.pnorm(z-@distribution.qnorm(1-@onePropAlpha/2))+@distribution.pnorm(-z-@distribution.qnorm(1-@OnePropAlpha/2))
    else
      @onePropPower=@distribution.pnorm(Math.sqrt(@onePropP0*(1-@onePropP0) / @onePropP / (1-@onePropP))*(Math.abs(z)-@distribution.qnorm(1-@onePropAlpha)))
    @onePropTTest()
    @onePropCheckRange()
    return

  onePropPowerTon: () ->
    # calculate n1 or n2 from power based on different mdoes
    if @mode is "Two Sided"
      @onePropN = @onePropP*(1-@onePropP)*Math.pow(((@distribution.qnorm(1-@onePropAlpha / 2)+@distribution.qnorm(@onePropPower))/(@onePropP-@onePropP0)),2)
    else
      @onePropN = @onePropP0*(1-@onePropP0)*Math.pow(((@distribution.qnorm(1-@onePropAlpha)+@distribution.qnorm(@onePropAlpha)*Math.sqrt(@onePropP*(1-@onrPropP)/ @onePropP0/ (1-@onePropP0)))/(@onePropP-@onePropP0)),2)
    @onePropTTest()
    @onePropCheckRange()
    return

  onePropTTest: () ->
    # df = Math.round(@onePropN - 1)
    # @oneTestT = (@oneTestMean - @oneTestMean0) / (@oneTestStDev / Math.sqrt(@oneTestN))
    # @oneTestPvalue = 1 - @tProb(df, @oneTestT)
    # @oneTestPvalue *= 2 if @oneTestMode is 'Two Tailed'
    # @oneTestPvalue = Math.max(0, @oneTestPvalue)
    # @oneTestPvalue = Math.min(1, @oneTestPvalue)
    return 0

  getRightBound: (middle,step) ->
    return middle + step * @distanceFromMean

  getLeftBound: (middle,step) ->
    return middle - step * @distanceFromMean

  getVariance: (values, mean) ->
    temp = 0
    numberOfValues = values.length
    while( numberOfValues--)
      temp += Math.pow( (parseInt(values[numberOfValues]) - mean), 2 )
    return temp / values.length

  getSum: (values) ->
    values.reduce (previousValue, currentValue) -> parseFloat(previousValue) + parseFloat(currentValue)

  getGaussianFunctionPoints: (mean, std, leftBound, rightBound) ->
    data = []
    for i in [leftBound...rightBound]
      data.push
        x: i
        y: (1 / (std * Math.sqrt(Math.PI * 2))) * Math.exp(-(Math.pow(i - mean, 2) / (2 * Math.pow(std, 2))))
    data

  getMean: (valueSum, numberOfOccurrences) ->
    valueSum / numberOfOccurrences

  getChartData: () ->
    mean = 0
    stdDev = Math.sqrt(@onePropP0*(1-@onePropP0) / @onePropP / (1-@onePropP))
    alpha = @onePropAlpha

    rightBound = @getRightBound(mean, stdDev)
    leftBound =  @getLeftBound(mean, stdDev)
    bottomBound = 0
    topBound = 1 / (stdDev * Math.sqrt(Math.PI * 2))
    gaussianCurveData = @getGaussianFunctionPoints(mean, stdDev, leftBound, rightBound)

    bounds =
      left: leftBound
      right: rightBound
      top: topBound
      bottom: bottomBound

    data = [gaussianCurveData]

    return {
      data: data
      bounds: bounds
    }

  tProb: ($n, $x) ->
    if $n <= 0
      throw 'Invalid n: $n\n'
      ### degree of freedom ###
    @precisionString @subTProb($n - 0, $x - 0)

  integer: ($i) ->
    if $i > 0
      Math.floor $i
    else
      Math.ceil $i

  precisionString: ($x) ->
    if $x
      @roundToPrecision $x, @precision($x)
    else
      '0'

  roundToPrecision: ($x, $p) ->
    $x = $x * 10 ** $p
    $x = Math.round($x)
    $x / 10 ** $p

  precision: ($x) ->
    Math.abs @integer(@log10(Math.abs($x)) - @SIGNIFICANT)

  subTProb: ($n, $x) ->
    $a = undefined
    $b = undefined
    $w = Math.atan2($x / Math.sqrt($n), 1)
    $z = Math.cos($w) ** 2
    $y = 1
    $i = $n - 2
    while $i >= 2
      $y = 1 + ($i - 1) / $i * $z * $y
      $i -= 2
    if $n % 2 == 0
      $a = Math.sin($w) / 2
      $b = .5
    else
      $a = if $n == 1 then 0 else Math.sin($w) * Math.cos($w) / Math.PI
      $b = .5 + $w / Math.PI
    @max 0, 1 - $b - ($a * $y)

  log10: ($n) ->
    Math.log($n) / Math.log(10)

  max: () ->
    $max = arguments[0]
    $i = 0
    while $i < arguments.length
      if $max < arguments[$i]
        $max = arguments[$i]
      $i++
    $max

  tDistr: ($n, $p) ->
    if $n <= 0
      throw 'Invalid n: $n\n'
    if $p <= 0 or $p >= 1
      throw 'Invalid p: $p\n'
    @precisionString @subT($n - 0, $p - 0)

  subT: ($n, $p) ->
    if $p >= 1 or $p <= 0
      throw 'Invalid p: $p\n'
    if $p == 0.5
      return 0
    else if $p < 0.5
      return -@subT($n, 1 - $p)
    $u = @subU($p)
    $u2 = $u ** 2
    $a = ($u2 + 1) / 4
    $b = ((5 * $u2 + 16) * $u2 + 3) / 96
    $c = (((3 * $u2 + 19) * $u2 + 17) * $u2 - 15) / 384
    $d = ((((79 * $u2 + 776) * $u2 + 1482) * $u2 - 1920) * $u2 - 945) / 92160
    $e = (((((27 * $u2 + 339) * $u2 + 930) * $u2 - 1782) * $u2 - 765) * $u2 + 17955) / 368640
    $x = $u * (1 + ($a + ($b + ($c + ($d + $e / $n) / $n) / $n) / $n) / $n)
    if $n <= @log10($p) ** 2 + 3
      $round = undefined
      loop
        $p1 = @subTProb($n, $x)
        $n1 = $n + 1
        $delta = ($p1 - $p) / Math.exp(($n1 * Math.log($n1 / ($n + $x * $x)) + Math.log($n / $n1 / 2 / Math.PI) - 1 + (1 / $n1 - (1 / $n)) / 6) / 2)
        $x += $delta
        $round = @roundToPrecision($delta, Math.abs(@integer(@log10(Math.abs($x)) - 4)))
        unless $x and $round != 0
          break
    $x

  subU: ($p) ->
    $y = -Math.log(4 * $p * (1 - $p))
    $x = Math.sqrt($y * (1.570796288 + $y * (.03706987906 + $y * (-.8364353589e-3 + $y * (-.2250947176e-3 + $y * (.6841218299e-5 + $y * (0.5824238515e-5 + $y * (-.104527497e-5 + $y * (.8360937017e-7 + $y * (-.3231081277e-8 + $y * (.3657763036e-10 + $y * .6936233982e-12)))))))))))
    if $p > .5
      $x = -$x
    $x