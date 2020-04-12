xquery version "3.0";
declare variable $local:centre := (51.47,-2.594697);
declare variable $local:root := "E06000023";
declare variable $local:googlekey  := "AIzaSyB-sB9Nwqkh-imfUd1-w3_lz4KFhL-_VqU";
declare variable $local:benefit-factors := doc("benefit-factors.xml")/benefits;

declare option exist:serialize "method=xhtml media-type=text/html";

<html>
    <head>
        <title>Bristol Tree Canopy - 2018</title>
  <link rel="stylesheet" type="text/css"
            href="https://fonts.googleapis.com/css?family=Merriweather Sans"/>
    <link rel="stylesheet" type="text/css"
            href="https://fonts.googleapis.com/css?family=Gentium Book Basic"/>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script> 
         <script src="https://maps.googleapis.com/maps/api/js?key={$local:googlekey}"></script> 
         <script type="text/javascript">
              var centre =  new google.maps.LatLng({$local:centre[1]},{$local:centre[2]});
              var root ='{$local:root}';
        </script>
         <script type="text/javascript" src="treecanopy.js"></script> 
         <meta name="viewport" content="width=device-width, initial-scale=1"/>
    <link rel="icon" href="assets/icons/BTF128.png" sizes="128x128" />
    <link rel="shortcut icon" type="image/png" href="BTF128.png"/>
    <link rel="stylesheet" type="text/css" href="tcc.css" media="screen" ></link>
    <link rel="stylesheet" type="text/css" href="tcc-phone.css" media="print" ></link>
    <link rel="stylesheet" type="text/css" media="only screen and (max-device-width: 480px)" href="tcc-phone.css"  />
   
    </head>
        
    <body >
           <h2>Bristol Tree Canopy Cover Survey 2018 :
          display 
          <button id="TCC" onclick="color_polygons('TCC')">% Canopy Cover</button>&#160;
          <button id="m2p" onclick="color_polygons('m2p')">Sq m. canopy per person</button>&#160;   <button id="dep" onclick="color_polygons('dep')">Deprivation Score</button>&#160;   
          <a href="#background">About</a></h2>
          <div id="legend"/>
          <div id="canvas"/>
           <div id="text">
             <h2>Region details</h2>
             <div>Double-click on a region for data </div>
   
             <div id="info">
             
             </div>
             
           </div>
          
           <div id="background">
            <hr/>
               <h2>Background</h2>
               <h3>i-Tree Canopy</h3>
               <div>
This Tree Canopy Cover (TCC) data is based on our work with <a class="external" target="_blank" href="https://canopy.itreetools.org">i-Tree Canopy</a>. This tool uses Google Earth imagery and allows the user to select a number of random sample points in a pre-defined region, in this case a Bristol Ward.  If a sample point falls on any tree canopy it is defined 'tree', otherwise it is defined as 'non-tree' . Once enough sample points have been collected, it is possible to estimate the percentage TCC for the region. </div>
<div>The TCC estimates in this analysis are the work of Mark Ashdown, Chair of <a  class="external" target="_blank" href="https://bristoltreeforum.org/">Bristol Tree Forum</a> based on Google Earth imagery of April 2018. Forestry Research are compiling TCC data from across the UK and it is mapped <a  class="external" target="_blank" href="http://forestry.maps.arcgis.com/apps/webappviewer/index.html?id=d8c253ab17e1412586d9774d1a09fa07"> here</a>.
               </div>
              
               <h2>i-Tree Eco</h2>
               <div>The <a  class="external" target="_blank" href="https://forestofavontrust.org/projects-detail/itree-the-benefits-of-trees">i-Tree Eco survey </a> undertaken by Forest of Avon Trust in 2018 arrived at a much lower overall estimate of TCC than the i-Tree Canopy method has provided, with an overall figure of 11.9%. The data for each region includes the pro-rated i-Tree Eco value.</div>
                <h2>Conversion factors and benefit values used</h2>
                <div>The prediction of environmental impacts from only an estimate of the tree canopy area uses US-based factors so is not calibrated for UK conditions. In that context, there is considerable uncertainly in extrapolating the data to the UK.  The factors are shown below but the computed values derived from them must be treated with great scepticism because of this.
               </div>
               <div>Estimates of the monetary benefits of those impacts is also subject to debate.  The values shown below are based on those suggested by <a class="external" target="_blank"  href="https://www.forestresearch.gov.uk/research/i-tree-eco/i-tree-resources/reporting-an-i-tree-eco-project/">Forestry Research</a> which uses figures from the UK government <a  class="external" target="_blank" href="https://www.gov.uk/guidance/air-quality-economic-analysis">Air Quality: economic analysis</a> [now withdrawn]. The figures have wide ranges of sensitivity.
               </div>
                <table> 
                     <tr><th>Component</th><th>description</th><th>kg/m<sup>2</sup>/yr</th><th>£ per tonne</th></tr>
                     {for $benefit in $local:benefit-factors/benefit
                     let $heading := util:parse(concat("<span>",$benefit/html,"</span>"))
                     return 
                          <tr><th>{$heading}</th><td>{$benefit/name}</td><td>{$benefit/factor}</td><td>{$benefit/pounds}</td></tr>
                     }
                </table>
                <div><span><b>Estimated number of trees / hectare @ 2.5m radius</b></span>&#160;&#160;<span> : 250</span></div>
                
                <div><h2>Deprivation Score</h2>The Deprivation score for wards is based on 2015 data from <a class="external" target="_blank"  href="https://www.bristol.gov.uk/statistics-census-information/deprivation">Bristol City Council</a> by postcode. It has been re-aggregated for the current ward boundaries. The lower the score, the higher the level of deprivation.</div>
                <hr/>
                <div> A <a class="external" target="_blank" href="https://bristoltreeforum.org/"><img src="assets/icons/BTF128.png" width="50"/></a> production.  Code and data on <a href="https://github.com/KitWallace/TCC">GitHub</a>.</div>
           
        </div>   
    </body>
    
    
    
</html>
