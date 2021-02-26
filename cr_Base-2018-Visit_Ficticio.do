version 14.0
cap log close
cap mkdir Logs
log using Logs/cr_Base-2018-Visit_Ficticio.log, replace
set linesize 255
set more off
clear
set maxvar 32767, perm

cap mkdir "Bases"

import excel "Input/Visit_2018_Ficticio.xlsx", sheet("2018") firstrow

label var AP "Área Protegida - Portada"
label var Categ "Categoría de Manejo"
label var Reg "Región"
label var Port "Portadas totales y subtotales"
label var Clasif_Port "Clasificación AP según portadas"
label var Acceso "Cobro de derechos de acceso"
label var AP_Separador "Área Protegida"

list if AP ==""
drop if AP ==""

foreach var of varlist _all {
            cap confirm str variable `var'
			if _rc != 7 {
			    replace `var' = trim(`var')
            }
}

label data                                                                        ///
"Visitación 2018 - APN DNUP DM. Fuente: DATOS FICTICIOS."

*Reemplazo de valores missing por "0"
qui forval i = 1/12 {
        foreach j in ext nacmay rprov rloc est jp men {
			replace m`i'_2018`j' = 0 if m`i'_2018`j'==.
    }
}

*Cálculo de totales
qui set obs `=_N+1'
qui forval i =1/12 {
        qui foreach j in ext nacmay rprov rloc est jp men {
    	        summ m`i'_2018`j' in 1/`=_N-2'
				scalar tot_m`i'_2018`j' =r(sum)
				replace m`i'_2018`j' = tot_m`i'_2018`j' in L
	    }
}
qui scalar drop _all

*Comparación cálculo totales contra totales del Input
qui forval i =1/12 {
        qui foreach j in ext nacmay rprov rloc est jp men {
	        assert m`i'_2018`j'[_N] == m`i'_2018`j'[_N-1]    
	    }
}
qui drop in L

*Total por mes y categoría en AP con más de una portada"
valuesof AP if Clasif_Port=="MULTIPORT" & Port=="Total" 
local AP_Multiport = r(values)

qui foreach i of local AP_Multiport { 
        forval j =1/12 { 
            foreach k in ext nacmay rprov rloc est jp men {
				summ m`j'_2018`k' if strpos(AP,"`i'") & Port=="Subtotal"
				scalar tot_m`j'_2018`k' =r(sum)
				replace m`j'_2018`k' = tot_m`j'_2018`k' if strpos(AP,"`i'")       ///
				& Port=="Total"
	    
	        }
        }
}  

qui scalar drop _all

*Totales mensuales: Total Sistema, AP's que cobran y que no cobran
qui forval i =1/12 {
        *Genera totales por AP
        egen m`i'_2018total = rowtotal(m`i'_2018*)
        
}			
scalar drop _all

*Genera categoría "nactotal"
qui forval i =1/12 {  
	gen m`i'_2018nactotal = m`i'_2018total - m`i'_2018ext
}

*Totales trimestrales y semestrales
qui foreach i in ext nacmay rprov rloc est jp men total nactotal {
	*Totales trimestrales
	egen trim1_2018`i' = rowtotal(m1_2018`i' m2_2018`i' m3_2018`i')	
	egen trim2_2018`i' = rowtotal(m4_2018`i' m5_2018`i' m6_2018`i')	
	egen trim3_2018`i' = rowtotal(m7_2018`i' m8_2018`i' m9_2018`i')	
	egen trim4_2018`i' = rowtotal(m10_2018`i' m11_2018`i' m12_2018`i')	
	*Totales semestrales
	egen sem1_2018`i' = rowtotal(trim1_2018`i' trim2_2018`i')
	egen sem2_2018`i' = rowtotal(trim3_2018`i' trim4_2018`i')
	*Totales anuales
	egen total_2018`i' = rowtotal(sem1_2018`i' sem2_2018`i')
}

*Acumulados mensuales
qui foreach i in ext nacmay rprov rloc est jp men total nactotal {
	gen ac1_2018`i'= m1_2018`i'
	egen ac2_2018`i' = rowtotal(ac1_2018`i' m2_2018`i')
	egen ac3_2018`i' = rowtotal(ac2_2018`i' m3_2018`i')
	egen ac4_2018`i' = rowtotal(ac3_2018`i' m4_2018`i')
	egen ac5_2018`i' = rowtotal(ac4_2018`i' m5_2018`i')
	egen ac6_2018`i' = rowtotal(ac5_2018`i' m6_2018`i')
	egen ac7_2018`i' = rowtotal(ac6_2018`i' m7_2018`i')
	egen ac8_2018`i' = rowtotal(ac7_2018`i' m8_2018`i')
	egen ac9_2018`i' = rowtotal(ac8_2018`i' m9_2018`i')
	egen ac10_2018`i' = rowtotal(ac9_2018`i' m10_2018`i')
	egen ac11_2018`i' = rowtotal(ac10_2018`i' m11_2018`i')
	egen ac12_2018`i' = rowtotal(ac11_2018`i' m12_2018`i')
}

*Etiquetado
local sufijovar ext nacmay rprov rloc est jp men total nactotal
local etiq Extranjeros "Nacionales Mayores" "Residentes Provinciales"             ///
"Residentes Locales" Estudiantes "Jubilados y Pensionados" Menores Total          ///
"Total Nacionales" 

*Etiquetas mensuales
local foo = 1
foreach i in `sufijovar' {
    local e : word `foo' of `etiq'
    forval k = 1/12 {
        foreach j in "`e'" {
            label var m`k'_2018`i' "`k'/2018 `j'" 
            label var ac`k'_2018`i' "Acumulado `k'/2018 `j'"
        }
    }
    local foo = `foo' + 1
}

*Etiquetas trimestrales
local foo = 1
foreach i in `sufijovar' {
    local e : word `foo' of `etiq'
    forval k = 1/4 {
        foreach j in "`e'" {
            label var trim`k'_2018`i' "Trimestre `k'/2018 `j'" 
        }
    }
    local foo = `foo' + 1
}	

*Etiquetas semestrales	
local foo = 1
foreach i in `sufijovar' {
    local e : word `foo' of `etiq'
    forval k = 1/2 {
        foreach j in "`e'" {
            label var sem`k'_2018`i' "Semestre `k'/2018 `j'" 
        }
    }
    local foo = `foo' + 1
}

local etiq Extranjeros "Nacionales Mayores" "Residentes Provinciales"             ///
"Residentes Locales" Estudiantes "Jubilados y Pensionados" Menores                ///
"Visitación" "Nacionales"

*Etiquetas total
local foo = 1
foreach i in `sufijovar' {
    local e : word `foo' of `etiq'
    foreach j in "`e'" {
        label var total_2018`i' "Total `e' 2018" 
    }
    local foo = `foo' + 1
}

*Formato
format %11,0gc m* trim* sem* total* ac*

*Ordeno variables
forval i =1/12 {
	order m`i'_2018total, after(m`i'_2018men)
}

forval i =1/4 { 
	order trim`i'_2018total, after(trim`i'_2018men)
}

forval i =1/2 {
	order sem`i'_2018total, after(sem`i'_2018men)
}
order total_2018ext total_2018nacmay total_2018rprov total_2018rloc               ///
total_2018est total_2018jp total_2018men total_2018total, after(sem2_2018total)


*Notas
notes _dta: "Diseño y programación: Lic. Franco Germán Barone"
notes _dta: Gnerado TS 

compress
cap mkdir Bases
save "Bases/2018-Visit_Ficticio.dta", replace

*Exporto base
drop Cat* Reg* Port* Clasif* Acceso* AP_Sep* *nactotal ac* 
cap export excel using "Bases exportadas\2018-Visit_Ficticio.xlsx",               ///
firstrow(varlabels) replace

notes
log close
exit
