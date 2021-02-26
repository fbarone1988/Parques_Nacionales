version 14.0
cap log close
cap mkdir Logs
log using Logs/cr_Base-2019-Visit_Ficticio.log, replace
set linesize 255
set more off
clear
set maxvar 32767, perm

cap mkdir "Bases"

import excel "Input/Visit_2019_Ficticio.xlsx", sheet("2019") firstrow

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
"Visitación 2019 - APN DNUP DM. Fuente: DATOS FICTICIOS."

*Reemplazo de valores missing por "0"
qui forval i = 1/12 {
        foreach j in ext nacmay rprov rloc est jp men {
			replace m`i'_2019`j' = 0 if m`i'_2019`j'==.
    }
}

*Cálculo de totales
qui set obs `=_N+1'
qui forval i =1/12 {
        qui foreach j in ext nacmay rprov rloc est jp men {
    	        summ m`i'_2019`j' in 1/`=_N-2'
				scalar tot_m`i'_2019`j' =r(sum)
				replace m`i'_2019`j' = tot_m`i'_2019`j' in L
	    }
}
qui scalar drop _all

*Comparación cálculo totales contra totales del Input
qui forval i =1/12 {
        qui foreach j in ext nacmay rprov rloc est jp men {
	        assert m`i'_2019`j'[_N] == m`i'_2019`j'[_N-1]    
	    }
}
qui drop in L

*Total por mes y categoría en AP con más de una portada"
valuesof AP if Clasif_Port=="MULTIPORT" & Port=="Total" 
local AP_Multiport = r(values)

qui foreach i of local AP_Multiport { 
        forval j =1/12 { 
            foreach k in ext nacmay rprov rloc est jp men {
				summ m`j'_2019`k' if strpos(AP,"`i'") & Port=="Subtotal"
				scalar tot_m`j'_2019`k' =r(sum)
				replace m`j'_2019`k' = tot_m`j'_2019`k' if strpos(AP,"`i'")       ///
				& Port=="Total"
	    
	        }
        }
}  

qui scalar drop _all

*Totales mensuales: Total Sistema, AP's que cobran y que no cobran
qui forval i =1/12 {
        *Genera totales por AP
        egen m`i'_2019total = rowtotal(m`i'_2019*)
        
}			
scalar drop _all

*Genera categoría "nactotal"
qui forval i =1/12 {  
	gen m`i'_2019nactotal = m`i'_2019total - m`i'_2019ext
}

*Totales trimestrales y semestrales
qui foreach i in ext nacmay rprov rloc est jp men total nactotal {
	*Totales trimestrales
	egen trim1_2019`i' = rowtotal(m1_2019`i' m2_2019`i' m3_2019`i')	
	egen trim2_2019`i' = rowtotal(m4_2019`i' m5_2019`i' m6_2019`i')	
	egen trim3_2019`i' = rowtotal(m7_2019`i' m8_2019`i' m9_2019`i')	
	egen trim4_2019`i' = rowtotal(m10_2019`i' m11_2019`i' m12_2019`i')	
	*Totales semestrales
	egen sem1_2019`i' = rowtotal(trim1_2019`i' trim2_2019`i')
	egen sem2_2019`i' = rowtotal(trim3_2019`i' trim4_2019`i')
	*Totales anuales
	egen total_2019`i' = rowtotal(sem1_2019`i' sem2_2019`i')
}

*Acumulados mensuales
qui foreach i in ext nacmay rprov rloc est jp men total nactotal {
	gen ac1_2019`i'= m1_2019`i'
	egen ac2_2019`i' = rowtotal(ac1_2019`i' m2_2019`i')
	egen ac3_2019`i' = rowtotal(ac2_2019`i' m3_2019`i')
	egen ac4_2019`i' = rowtotal(ac3_2019`i' m4_2019`i')
	egen ac5_2019`i' = rowtotal(ac4_2019`i' m5_2019`i')
	egen ac6_2019`i' = rowtotal(ac5_2019`i' m6_2019`i')
	egen ac7_2019`i' = rowtotal(ac6_2019`i' m7_2019`i')
	egen ac8_2019`i' = rowtotal(ac7_2019`i' m8_2019`i')
	egen ac9_2019`i' = rowtotal(ac8_2019`i' m9_2019`i')
	egen ac10_2019`i' = rowtotal(ac9_2019`i' m10_2019`i')
	egen ac11_2019`i' = rowtotal(ac10_2019`i' m11_2019`i')
	egen ac12_2019`i' = rowtotal(ac11_2019`i' m12_2019`i')
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
            label var m`k'_2019`i' "`k'/2019 `j'" 
            label var ac`k'_2019`i' "Acumulado `k'/2019 `j'"
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
            label var trim`k'_2019`i' "Trimestre `k'/2019 `j'" 
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
            label var sem`k'_2019`i' "Semestre `k'/2019 `j'" 
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
        label var total_2019`i' "Total `e' 2019" 
    }
    local foo = `foo' + 1
}

*Formato
format %11,0gc m* trim* sem* total* ac*

*Ordeno variables
forval i =1/12 {
	order m`i'_2019total, after(m`i'_2019men)
}

forval i =1/4 { 
	order trim`i'_2019total, after(trim`i'_2019men)
}

forval i =1/2 {
	order sem`i'_2019total, after(sem`i'_2019men)
}
order total_2019ext total_2019nacmay total_2019rprov total_2019rloc               ///
total_2019est total_2019jp total_2019men total_2019total, after(sem2_2019total)


*Notas
notes _dta: "Diseño y programación: Lic. Franco Germán Barone"
notes _dta: Generado TS 

compress
cap mkdir Bases
save "Bases/2019-Visit_Ficticio.dta", replace

*Exporto base
drop Cat* Reg* Port* Clasif* Acceso* AP_Sep* *nactotal ac* 
cap export excel using "Bases exportadas\2019-Visit_Ficticio.xlsx",               ///
firstrow(varlabels) replace

notes
log close
exit
