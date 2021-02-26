version 14.0
cap log close
cap mkdir Logs
log using "Logs/gr_2019_2018-Visit-Composic_Ficticio.log", replace
set linesize 255
set more off
clear

cap mkdir "Gráficos"
cap mkdir "Gráficos/2019/Composición"
cap mkdir "Gráficos/2019/Composición/AP"
cap mkdir "Gráficos/2019/Composición/AP/Nacionales_desagregado"
cap mkdir "Gráficos/2019/Composición/AP/Extranjeros_Nacionales"

use "Bases/2019-Visit_Ficticio"
merge 1:m AP using "Bases/2018-Visit_Ficticio.dta"
drop if Port=="Subtotal" 
keep AP Reg Categ* Port Acceso total_2019* total_2018*
replace Reg = proper(Reg) in 1/`=_N-1'
drop if Port =="Subtotal"

replace Categ = "Parque Nacional" if Categ =="PN"
replace Categ = "Reserva Natural Educativa" if Categ =="RNEd"
replace Categ = "Reserva Natural" if Categ =="RNat"
replace Categ = "Monumento Natural" if Categ =="MN"
replace Categ = "Reserva Nacional" if Categ =="RNac"

gen AP_Cat = Categ+" "+AP
replace AP_Cat= "Total de Áreas Protegidas" if AP_Cat =="Total AP Total AP"

levelsof AP_Cat if total_2019total >0, local(AP_Cat) 
label var AP_Cat "Categoría + nombre AP"
/*
// 0) Pie "Composición de la visitación nacionales 2019
foreach i of local AP_Cat {
	graph pie total_2019nacmay total_2019rprov total_2019rloc                     ///
		  total_2019est total_2019jp total_2019men if AP_Cat == "`i'",            ///                                                 
		  legend(label(1 "Nac. Mayores") label(2 "Res. Provinciales")             ///
		  label(3 "Res. Locales") label(4 "Estudiantes")                          ///
          label(5 "Jub. y Pens.") label(6 "Menores"))                             ///
		  legend(size(vsmall) region(lwidth(none)) cols(6)) plabel(_all per ,     ///
          format(%9.0f) size(small) color(white)) ysize(10) xsize(20)             ///
		  graphregion(fcolor(white))                                              ///
		  title("`i'")                                                            ///
	      subtitle("Composición de visitantes nacionales 2019",lcolor(gs12)       ///
          fcolor(gs15))                                                           ///
		  note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") 
	graph export "Gráficos/2019/Composición/AP/Nacionales_desagregado/`i'_xNac_2019_pie.png", ///
		  width(1000) replace 	  
}

// 0) Pie "Composición de la visitación Ext-Nac
foreach i of local AP_Cat {
	graph pie total_2019ext total_2019nactotal if AP_Cat == "`i'",                ///                                                 
		  legend(label(1 "Extranjeros") label(2 "Nacionales"))                    ///
		  legend(size(vsmall) region(lwidth(none))) plabel(_all per ,             ///
          format(%9.0f) size(small) color(white)) ysize(10) xsize(20)             ///
		  graphregion(fcolor(white))                                              ///
		  title("`i'")                                                            ///
		  subtitle("Visitantes nacionales y extranjeros 2019",lcolor(gs12)        ///
          fcolor(gs15))                                                           ///  
		  note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") 
	graph export "Gráficos/2019/Composición/AP/Extranjeros_Nacionales/`i'_xExt-Nac_2019_pie.png", ///
		  width(1000) replace 
	  
}
*/
// 1) Pie "Composición de la visitación total y por región 2019"
graph pie total_2019ext total_2019nacmay total_2019rprov total_2019rloc           ///
      total_2019est total_2019jp total_2019men if total_2019total>0, by(Reg,      ///
      graphregion(fcolor(white))                                                  ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") ///
      title("Composición de la visitación total y por región 2019"))              ///                         
      legend(label(1 "Extranjeros") label(2 "Nac. Mayores")                       ///
      label(3 "Res. Provinciales")label(4 "Res.Locales")                          ///
      label(5 "Estudiantes") label(6 "Jub. y Pens.")                              ///
      label(7 "Menores"))                                                         ///
      legend(size(vsmall) region(lwidth(none)) cols(7)) plabel(_all per ,         ///
      format(%9.0f) size(vsmall) color(white)) ysize(10) xsize(20)                ///
      subtitle(,lcolor(gs12) fcolor(gs15))                                   
graph export "Gráficos/2019/Composición/1_Visit_xCat_2019reg_pie.png",            ///
      width(1000) replace

label var total_2019ext "Extranjeros"
label var total_2019nacmay "Nac. Mayores"
label var total_2019rprov "Res. Provinciales"
label var total_2019rloc "Res. Locales"
label var total_2019est "Estudiantes"
label var total_2019jp "Jub. y Pens."
label var total_2019men "Menores"

// 2) Bar "Composición de la visitación por región y total 2019"
graph hbar (sum) total_2019ext total_2019nacmay total_2019rprov                   ///
      total_2019rloc total_2019est total_2019jp total_2019men if                  ///
      total_2019total>0, by(Reg, graphregion(fcolor(white))                       /// 
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") ///
      title("Composición de la visitación por región y total 2019")               ///
      subtitle("% de visitantes"))                                                ///
      stack percent blabel(bar, color(white) position(center) size(vsmall)        ///
      format(%9.0f) justification(center))                                        ///
      legend(region(lwidth(none)) size(vsmall) cols(7)) xsize(20) ysize(10)       ///
      scale(1) graphregion(color(white)) ytitle("") ylabel(,nogrid)               ///
      yvar(relabel(1 "`: var label total_2019ext'"                                ///
      2 "`: var label total_2019nacmay'" 3 "`: var label total_2019rprov'"        ///
      4 "`: var label total_2019rloc'" 5 "`: var label total_2019est'"            ///
      6 "`: var label total_2019jp'" 7 "`: var label total_2019men'"))            ///
      subtitle(,lcolor(gs12) fcolor(gs15)) play("Gráficos/2019/Composición/Preferencias/P1")

	  local ng=`.Graph.graphs.arrnels'
	  forval g=1/`ng' {
		  local nb=`.Graph.graphs[`g'].plotregion1.barlabels.arrnels'
		  forval i=1/`nb' {
			  di "`.Graph.graphs[`g'].plotregion1.barlabels[`i'].text[1]'"
			  .Graph.graphs[`g'].plotregion1.barlabels[`i'].text[1]="`.Graph.graphs[`g'].plotregion1.barlabels[`i'].text[1]'%"
		  }
	   }
	   .Graph.drawgraph
	   graph export "Gráficos/2019/Composición/2_Comp_2019hbar.png",              ///
	   width(1000)replace

// 3) Pie "Composición de la visitación por región y total 2019"
replace Reg = "del total de Áreas Protegidas" in L
foreach i in Nea Noa Patagonia Centro "del total de Áreas Protegidas" {
    graph pie total_2019ext total_2019nacmay total_2019rprov total_2019rloc       ///
          total_2019est total_2019jp total_2019men if Reg == "`i'",               ///
	      title("Composición visitación `i' 2019")                                ///
          graphregion(fcolor(white)) legend(region(lwidth(none))                  ///
	      size(vsmall) cols(7)) plabel(_all per , format(%9.0f) size(small)       ///           
	      color(white)) ysize(10) xsize(20) subtitle(,lcolor(gs12)                ///
	      fcolor(gs15))                                                           ///    
          note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") 
    graph export "Gráficos/2019/Composición/3_Comp_`i'_2019pie.png",              ///
          width(1000)replace
}

foreach i in ext nacmay rprov rloc est jp men total nactotal {
    rename (total_2018`i' total_2019`i') `i'#, addnumber
}
reshape long ext nacmay rprov rloc est jp men total nactotal, i(AP) j(Año) 
sort total
replace Año=2018 if Año==1
replace Año=2019 if Año==2

// 4) Bar "Visitación por tipo de visitante 2018-2019" (CANTIDAD)
graph bar (sum) ext nacmay rprov rloc est jp men if AP !="Total AP",              /// 
      over(Año, axis(lcolor(white))) stack                                        ///
      blabel(bar, color(white) position(center) format(%12,0gc)                   ///
      justification(center) size(small)) yscale(off) yscale(noline)               ///
      ylabel(,nolabels nogrid) ymtick(none, noticks nogrid)                       ///
      legend(region(lwidth(none)) size(vsmall) cols(3)                            ///
      label(1 "Extranjeros") label(2 "Nac. Mayores")                              ///
      label(3 "Res. Provinciales") label(4 "Res. Locales")                        ///
      label(5 "Estudiantes") label(6 "Jub. y Pens.")                              ///
      label(7 "Menores"))title("Visitación por tipo de visitante 2018-2019")      ///                         
      subtitle("Cantidad de visitantes")                                          ///
      clegend(region(lcolor(white))altaxis size(vsmall)) ysize(15) xsize(20)      ///
      graphregion(color(white) fcolor(white)) ylabel(,format(%11,0gc))            ///
      ytitle("Visitantes")                                                        ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.", size(*0.62))
graph export "Gráficos/2019/Composición/4_Visit_xCat_2019_bar.png",               ///
      width(1000)replace

// 5) Bar "Visitación por tipo de visitante 2018-2019" (%)
graph hbar (sum) ext nacmay rprov rloc est jp men if AP !="Total AP",             /// 
      over(Año, axis(lcolor(white))) stack percent                                ///
      blabel(bar, color(white) position(center) format(%11.0f)                    ///
      justification(center) size(small)) yscale(off) yscale(noline)               ///
      ylabel(, nogrid nolabels)                                                   ///
      ymtick(none, noticks nogrid) legend(region(lwidth(none)) cols(7)            ///
	  size(vsmall)                                                                ///
      label(1 "Extranjeros") label(2 "Nac. Mayores")                              ///
      label(3 "Res. Provinciales") label(4 "Res. Locales")                        ///
      label(5 "Estudiantes") label(6 "Jub. y Pens.")                              ///
      label(7 "Menores"))title("Visitación por tipo de visitante 2018-2019")      ///                        
      subtitle("% de visitantes")                                                 ///
      clegend(region(lcolor(white))altaxis) ysize(10) xsize(20)                   ///
      graphregion(color(white)) ylabel(,format(%11,0gc))                          ///
      ymtick(none, noticks nogrid) ytitle(Visitantes)                             ///
      graphregion(fcolor(white) color(white))                                     ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") 
graph export "Gráficos/2019/Composición/5_Visit_xCat_2019_bar%.png",         ///
      width(1000) replace

replace Reg = "Total AP" if Reg == "del total de Áreas Protegidas"
// 6) Bar "Visitación por Región y Total 2018-2019" (CANTIDAD)
graph bar (sum) total, over(Año, axis(lcolor(white)))                             ///
      over(Reg, sort((sum)total) axis(lcolor(white))) asyvars                     ///
      bar(1,color(edkblue)) bar(2,color(maroon))                                  ///
      clegend(region(lcolor(white))altaxis) blabel (bar, position(outside)        ///
      format(%12,0gc) color(black)) yscale(off) yscale(noline)                    ///
      ylabel(,nolabels nogrid) scale(*.75) legend(region(lwidth(none)))           ///
      ysize(20) xsize(20) ytitle(Visitantes)                                      ///
      subtitle("Cantidad de visitantes")                                          ///
      title("Visitación total y por región 2018-2019")                            ///
      graphregion(fcolor(white) color(white))                                     ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/6_Visit_xReg_2019_bar.png",               ///
width(1000) replace

// 7) Bar "Visitación por región 2018-2019"(%)
graph hbar (sum) total if AP!="Total AP", by(Año,graphregion(fcolor(white)))      ///
      yla(,labcolor(bg) tlength(0)) over(Reg) stack percent asyvars               ///                        
      bar(1, color(teal)) bar(2,color(forest_green)) bar(3,color(dkorange))       ///                       
      bar(4,color(ebblue)) ylabel(,nolabels nogrid) ytitle("")                    ///
      blabel(bar, position(center) format(%12.0f) color(white)                    ///
      size(medium)) graphregion(color(white) fcolor(white)) bgcolor(white)        ///
      ysize(10) xsize(20) legend(region(lwidth(none)) size(small) cols(5))        ///
      yscale(noline) subtitle(,lcolor(gs12) fcolor(gs15))                         ///
      by(Año, title("Visitación por región 2018-2019")                            ///
      subtitle("% de visitantes") scale(*.90)                                     ///                                 
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales."))

	  local ng=`.Graph.graphs.arrnels'
	  forval g=1/`ng' {
		  local nb=`.Graph.graphs[`g'].plotregion1.barlabels.arrnels'
		  forval i=1/`nb' {
		    di "`.Graph.graphs[`g'].plotregion1.barlabels[`i'].text[1]'"
		    .Graph.graphs[`g'].plotregion1.barlabels[`i'].text[1]="`.Graph.graphs[`g'].plotregion1.barlabels[`i'].text[1]'%"
		  }
	  }
	  .Graph.drawgraph

graph export "Gráficos/2019/Composición/7_Visit_xReg_2019_bar%.png",              ///
      width(1000) replace

// 8) Pie "Visitación por región 2018-2019"
graph pie total if AP!="Total AP", by(Año) over(Reg)                              ///
      graphregion(color(white) fcolor(white)) bgcolor(white) ysize(10)            ///
      xsize(20)legend(region(lwidth(none)))                                       ///
      by(Año, graphregion(fcolor(white)) title(                                   ///
      "Visitación por región 2018-2019") subtitle("% de visitantes")              ///                
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.") ///
      scale(*.90)) legend(size(small) region(lwidth(none)) cols(4))               ///
	  plabel(_all per, format(%9.0f) size(medsmall) color(white))                 ///
      pie(1, color(teal)) pie(2,color(forest_green)) pie(3,color(dkorange))       ///
      pie(4,color(ebblue)) subtitle(,lcolor(gs12) fcolor(gs15)) 
graph export "Gráficos/2019/Composición/8_Visit_xReg_2019_pie.png",               ///
      width(1000) replace

// 9) Bar "Visitación por categoría de Visitante 2018-2019" (%)
graph hbar (sum) ext nacmay rprov rloc est jp men, over(Año)                      ///
      over(Reg) stack percent ysize(10) xsize(20)                                 ///
      ylabel(,nogrid format(%11,0gc)) scale(*.80) ytitle(%)                       ///
      graphregion(fcolor(white)) blabel(bar,position(center) format(%12.0f)       ///
      color(white) size(vsmall)) legend(region(lwidth(none)) cols(7) size(small)  ///
      label(1 "Extranjeros") label(2 "Nac. Mayores")                              ///
      label(3 "Res. Provinciales") label(4 "Res. Locales")                        ///
      label(5 "Estudiantes") label(6 "Jub. y Pens.")                              ///
      label(7 "Menores")) subtitle("% de visitantes")                             ///
      title("Visitación por categoría de visitante 2018-2019")                    ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/9_Visit_xCat_2019reg_bar%.png",           ///
      width(1000) replace

drop if AP =="Total AP" | total ==0
gsort -Año -total      
gen orden = _n
replace orden =. if Año ==2018

// 10) Bar "Visitación de AP con cobro de derechos de acceso 2018-2019" (CANTIDAD)
graph bar (sum) total if Acceso=="COBRA" & total >0,                              ///
      over(Año, axis(lcolor(white)))                                              ///
      over(AP,sort(orden) axis(lcolor(white))                                     ///
      label(angle(45)labsize(vsmall))) asyvars bar(1,color(edkblue))              ///
      bar(2,color(maroon)) clegend(region(lcolor(white))altaxis)                  ///
      blabel(bar, position(outside) format(%12,1gc) color(black)                  ///
      size(vsmall)) yscale(off) yscale(noline) ylabel(,nolabels nogrid)           ///
      scale(*.90) legend(region(lwidth(none))) ysize(10) xsize(20)                ///
      ytitle(Visitantes) subtitle("Cantidad de visitantes")                       ///
      title("Visitación de AP con cobro de derechos de acceso 2018-2019")         ///
      graphregion(fcolor(white) color(white))                                     ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/10_Visit_Tot_2019cdacceso_bar.png",       ///
width(2000) replace  

// 11) Bar "Visitación de AP sin cobro de derechos de acceso 2018-2019" (CANTIDAD)
graph bar (sum) total if Acceso=="NO COBRA" & total >0,                      ///
      over(Año, axis(lcolor(white)))                                         ///
      over(AP,sort(orden) axis(lcolor(white))                                ///
      label(angle(45)labsize(vsmall))) asyvars bar(1,color(edkblue))         ///
      bar(2,color(maroon)) clegend(region(lcolor(white))altaxis)             ///
      blabel(bar, position(outside) format(%12,1gc) color(black) size(tiny)) ///
      yscale(off) yscale(noline) ylabel(,nolabels nogrid) scale(*.85)        ///
      legend(region(lwidth(none))) ysize(10) xsize(20) ytitle(Visitantes)    ///
      subtitle("Cantidad de visitantes")                                     ///
      title("Visitación de AP sin cobro de derechos de acceso 2018-2019")    ///
      graphregion(fcolor(white) color(white))                                ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/11_Visit_Tot_2019sdacceso_bar.png",  ///
width(2000) replace   

// 12) Bar "Visitación por cobro de derechos de acceso 2018-2019" (CANTIDAD)
graph bar (sum) total if AP !="Total AP", over(Año, axis(lcolor(white)))          ///
      over(Acceso, sort(orden) axis(lcolor(white))) asyvars                       ///
      bar(1,color(edkblue)) bar(2,color(maroon))                                  ///
      clegend(region(lcolor(white))altaxis) blabel(bar, position(outside)         ///
      format(%12,1gc) color(black) size(medsmall)) yscale(off) yscale(noline)     ///
      ylabel(,nolabels nogrid) scale(*.75) legend(region(lwidth(none)))           ///
      ysize(20) xsize(20) ytitle(Visitantes)                                      ///
      subtitle("Cantidad de visitantes")                                          ///
      title("Visitación por cobro de derechos de acceso 2018-2019")               ///
      graphregion(fcolor(white) color(white))                                     ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/12_Visit_Tot_2019xCDA_bar.png",           ///
width(1000) replace     

*Prepara base para hacer el Top 15 
replace AP = char(34)+AP[_n]+char(34)
levelsof AP in 1/5, clean sep(,) local(Top5) 
levelsof AP in 6/10, clean sep(,) local(Top10)
levelsof AP in 11/15, clean sep(,) local(Top15)
replace AP = subinstr(AP,char(34),"",.) 

// 13) Bar "Top 15 visitación 2018-2019" (CANTIDAD)
graph bar (sum) total if inlist(AP,`Top5') | inlist(AP,`Top10') |                 ///
      inlist(AP,`Top15'), over(Año, axis(lcolor(white)))                          ///
      over(AP,sort(orden)  axis(lcolor(white))                                    ///
      label(angle(45)labsize(vsmall))) asyvars bar(1,color(edkblue))              ///
      bar(2,color(maroon)) clegend(region(lcolor(white))altaxis)                  ///
      blabel(bar, position(outside) format(%12,1gc) color(black)                  ///
      size(tiny)) yscale(off) yscale(noline) ylabel(,nolabels nogrid)             ///
      scale(*.90) legend(region(lwidth(none))) ysize(10) xsize(20)                ///
      ytitle("Visitantes") subtitle("Cantidad de visitantes")                     ///
      title("Top 15 de visitación 2018-2019")                                     ///
      graphregion(fcolor(white) color(white))                                     ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/13_Visit_Top15_2019_bar.png",             ///
width(2000) replace 

// 14) Bar "Extranjeros Nacionales" (CANTIDAD) 
graph bar (sum) ext nactotal if inlist(AP,`Top5') | inlist(AP,`Top10'),           ///
      stack over(Año, axis(lcolor(white)) label(angle(45)))                       ///
      over(AP, sort(orden) label(angle(45)) axis(lcolor(white)))                  ///
      bar(1,color(edkblue))  bar(2,color(maroon))                                 ///
      clegend(region(lcolor(white))altaxis) blabel(bar, position(center)          ///
      format(%12,1gc) color(black) size(small)) yscale(off) yscale(noline)        ///
      ylabel(, labsize(small) nogrid) scale(*.70)                                 ///
      legend(region(lwidth(none)) label(1 "Extranjeros")                          ///
      label(2 "Nacionales")) ysize(10) xsize(20)                                  ///
      ytitle("Visitantes") subtitle("Cantidad de visitantes")                     ///
      title("Top 10 de visitación Nacionales y Extranjeros  2018-2019")           ///
      graphregion(fcolor(white) color(white))                                     ///
      note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
graph export "Gráficos/2019/Composición/14_Visit_Top10ext-nac_2019_bar.png",      ///
width(2000) replace 

window manage close graph
log close
exit