version 14.0
cap log close
cap mkdir Logs
log using Logs/gr_Graf-2019_2018-Visit-xCat_Mensual_Ficticio.log, replace
set linesize 255
set more off
clear

capture mkdir "Gráficos"
capture mkdir "Gráficos/2019"
capture mkdir "Gráficos/2019/Mensual"

foreach i in Extranjeros "Nacionales Mayores" "Residentes Provinciales"           /// 
    "Residentes Locales" "Estudiantes" "Jubilados y Pensionados" "Menores"        ///
    "Totales" "Nacionales" { 
    cap mkdir "Gráficos/2019/Mensual/`i'"
}

use "Bases/2019-Visit_Ficticio.dta"
merge 1:1 AP using "Bases/2018-Visit_Ficticio.dta", nogenerate

drop if Port =="Subtotal"
replace Categ = "Parque Nacional" if Categ =="PN"
replace Categ = "Reserva Natural Educativa" if Categ =="RNEd"
replace Categ = "Reserva Natural" if Categ =="RNat"
replace Categ = "Monumento Natural" if Categ =="MN"
replace Categ = "Reserva Nacional" if Categ =="RNac"

gen AP_Cat = Categ+" "+AP
replace AP_Cat= "Total de Áreas Protegidas" if AP_Cat =="Total AP Total AP"

levelsof AP_Cat, local(AP_Cat) 
label var AP_Cat "Categoría + nombre AP"

gen int año19=2019
gen int año18=2018
order año19, after (AP_Separador)
order año18, after (año19)
 
qui forval i = 18/19 {
		foreach j in ext nacmay rprov rloc est jp men total nactotal {
		rename m*_20`i'`j' `j'`i'#, addnumber
    }
}

local lista = "ext19 ext18 nacmay19 nacmay18 rprov19 rprov18 rloc19 rloc18 est19"
local lista = "`lista'" + " est18 jp19 jp18 men19 men18 total19 total18 nactotal19" 
local lista = "`lista'" + " nactotal18"

qui reshape long "`lista'", i(AP) j(Mes) 
gen ESmes = Mes
tostring ESmes, replace

tokenize Ene Feb Mar Abr May Jun Jul Ago Sep Oct Nov Dic 
qui forval i = 1/12 {  
		replace ESmes = "``i''" if Mes==`i'
}

label var Mes "Mes"

foreach i in 18 19 {
    foreach j in ext nacmay rprov rloc est jp men total nactotal {
        label var año`i'  "20`i'"
        label var `j'`i' "20`i'"
    }
}

labmask Mes, values(ESmes)

foreach j in ext nacmay rprov rloc est jp men total nactotal {
    order Mes, after (año18)
    order `j'19, before (`j'18)
}

drop Categ Reg Por Clasif Acc AP_Sep ESmes año* trim* sem* ac* total_*
 
gen pos = 9

order AP_Cat, after(AP)

local foo = 1
foreach j in ext nacmay rprov rloc est jp men total nactotal {
    foreach i of local AP_Cat {
        local k : word `foo' of Extranjeros "Nacionales Mayores"                  ///
	    "Residentes Provinciales" "Residentes Locales" Estudiantes                ///
        "Jubilados y Pensionados" Menores Totales "Nacionales"
	    twoway connected `j'19 `j'18 Mes if AP_Cat=="`i'",                        ///
	           legend(region(lcolor(white))) mlabv(pos) tlabel(#12,valuelabels)   ///                            /// 
	           graphregion(color(white))ylabels(,angle(horizontal)                ///
               format(%12,0gc) nogrid) ysize(10) xsize(20) mlabel(`j'19 `j'18 )   ///                                            ///
	           title("`i'") subtitle("Visitantes `k'") ytitle("Visitantes")       ///
               xtitle("Mes")                                                      ///
	           note("Fuente: DATOS FICTICIOS - Dirección de Mercadeo - Dirección Nacional de Uso Público - Administración de Parques Nacionales.")
	    graph export "Gráficos/2019/Mensual/`k'/`i'_`j'_Ficticio.png",            ///
        replace width(2000)
	}
    local foo = `foo' + 1
}

window manage close graph
log close

exit
