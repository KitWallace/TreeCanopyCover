xquery version "3.0";
import module namespace tp = "http://kitwallace.co.uk/lib/tp" at "../lib/tp.xqm";
import module namespace csv = "http://kitwallace.me/csv" at "/db/lib/csv.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:media-type "application/json";

let $areafilename := "/db/apps/trees/i-Tree/regiondata.csv"
let $csv := util:binary-to-string(util:binary-doc($areafilename))  
let $canopy := csv:convert-to-xml($csv, "regions", "region",",",(),2) 
let $benefits := doc("/db/apps/trees/tree-benefits/benefit-factors.xml")/benefits
let $itree-scaling := 0.6477
let $deprivation := doc("/db/apps/trees/sites/ward-deprivation.xml")
return 
    element regions {
        for $region in $canopy/region
        let $canopyRatio := round-half-to-even($region/CanopyRatio,4)
        let $itree_canopyRatio := round-half-to-even($canopyRatio * $itree-scaling,4)
   
        let $site := tp:get-site-by-sitecode($region/code)
        let $area := tp:get-sitecode-area($region/code)
        let $pop := $site/population
        let $canopy := round-half-to-even($site/hectares * $canopyRatio,3)
        let $canopyperperson :=round(( $canopy  div $pop)  * 10000 )
        let $dep := round-half-to-even($deprivation//ward[sitecode=$region/code]/deprivation,2)
        let $supersite := $site/supersite[category=("Area Committee","Council")]
        return 
           element region {
               $region/*,
               $site/name,
               $site/treecount,
               $site/hectares,
               $pop,
               if ($supersite) 
               then element supersite {$supersite/sitecode/string()}
               else (), 
               $site/category,
               element canopy {round-half-to-even($canopy)},
               element canopyperperson {$canopyperperson},
               element ratio {$canopyRatio},
               element itreeRatio {$itree_canopyRatio},
               element SEPC {round-half-to-even($region/SE * 100,2)},
               if ($dep) then element deprivation {$dep} else (),
               element analysis {
                   for $benefit in $benefits/benefit
                   let $tonnes := round($canopy * 10000 * $benefit/factor div 1000)   
                   let $money :=round-half-to-even($tonnes * $benefit/pounds,3)
                   return
                     element benefit {
                         $benefit/*,
                         element tonnes {$tonnes},
                         element total {$money}
                     }

               },
               if ($area and $region/code !="E06000023")
               then
                 element polygon {
                   for $point in $area/polygon/point
                   return 
                        element point {
                            element lat {round-half-to-even($point/@latitude,6)},
                            element lng {round-half-to-even($point/@longitude,6)}
                        }
               }
               else ()
        }
   }