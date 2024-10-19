# NSP-Flutter
this will the the mobile client for our Natural Story Progression project


- Run `flutter build ipa` to produce an Xcode build archive 
- open build/ios/archive/MyApp.xcarchive in Xcode, validate and expor the app via xcode


dev server is `https://boiling-escarpment-47456-9ae4c3f34de1.herokuapp.com`


## Colors
- Tailwind

{ 'aquamarine': { DEFAULT: '#0fedc7', 100: '#032f28', 200: '#065e4f', 300: '#098d77', 400: '#0cbc9f', 500: '#0fedc7', 600: '#3bf3d4', 700: '#6cf6df', 800: '#9df9e9', 900: '#cefcf4' }, 'rich_black': { DEFAULT: '#030810', 100: '#010203', 200: '#010307', 300: '#02050a', 400: '#03070e', 500: '#030810', 600: '#133263', 700: '#235bb6', 800: '#5a8ee0', 900: '#adc6ef' }, 'bittersweet': { DEFAULT: '#f05d5e', 100: '#3d0606', 200: '#790b0b', 300: '#b61111', 400: '#ea1f1f', 500: '#f05d5e', 600: '#f37c7c', 700: '#f69d9d', 800: '#f9bebe', 900: '#fcdede' }, 'chefchaouen_blue': { DEFAULT: '#4392f1', 100: '#041c39', 200: '#093872', 300: '#0d54ab', 400: '#1170e4', 500: '#4392f1', 600: '#67a6f4', 700: '#8dbdf6', 800: '#b3d3f9', 900: '#d9e9fc' }, 'sunglow': { DEFAULT: '#ffcb47', 100: '#412f00', 200: '#835e00', 300: '#c48c00', 400: '#ffb806', 500: '#ffcb47', 600: '#ffd56c', 700: '#ffe091', 800: '#ffeab6', 900: '#fff5da' } }

- CSV

0fedc7,030810,f05d5e,4392f1,ffcb47

- With #

#0fedc7, #030810, #f05d5e, #4392f1, #ffcb47

- Array

["0fedc7","030810","f05d5e","4392f1","ffcb47"]

- Object

{"Aquamarine":"0fedc7","Rich black":"030810","Bittersweet":"f05d5e","Chefchaouen Blue":"4392f1","Sunglow":"ffcb47"}

- Extended Array

[{"name":"Aquamarine","hex":"0fedc7","rgb":[15,237,199],"cmyk":[94,0,16,7],"hsb":[170,94,93],"hsl":[170,88,49],"lab":[84,-56,5]},{"name":"Rich black","hex":"030810","rgb":[3,8,16],"cmyk":[81,50,0,94],"hsb":[217,81,6],"hsl":[217,68,4],"lab":[2,0,-4]},{"name":"Bittersweet","hex":"f05d5e","rgb":[240,93,94],"cmyk":[0,61,61,6],"hsb":[360,61,94],"hsl":[360,83,65],"lab":[59,57,29]},{"name":"Chefchaouen Blue","hex":"4392f1","rgb":[67,146,241],"cmyk":[72,39,0,5],"hsb":[213,72,95],"hsl":[213,86,60],"lab":[60,7,-55]},{"name":"Sunglow","hex":"ffcb47","rgb":[255,203,71],"cmyk":[0,20,72,0],"hsb":[43,72,100],"hsl":[43,100,64],"lab":[84,6,69]}]

- XML

<palette>
  <color name="Aquamarine" hex="0fedc7" r="15" g="237" b="199" />
  <color name="Rich black" hex="030810" r="3" g="8" b="16" />
  <color name="Bittersweet" hex="f05d5e" r="240" g="93" b="94" />
  <color name="Chefchaouen Blue" hex="4392f1" r="67" g="146" b="241" />
  <color name="Sunglow" hex="ffcb47" r="255" g="203" b="71" />
</palette>