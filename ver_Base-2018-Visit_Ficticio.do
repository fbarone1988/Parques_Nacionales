version 14.0
cap log close
cap mkdir Logs
log using Logs/ver_Base-2018-Visit_Ficticio.log, replace
set linesize 255
set more off
clear

use "Bases/2018-Visit_Ficticio"

isid AP

assert AP =="Total AP" in L
assert inlist(Categ,"PN","RNac","RNat","MN","RNEd") in 1/`=_N-1'

assert Catego =="MN" if AP=="Laguna de los Pozuelos"
gen byte aux = 1 if strpos(AP, "-") & Port=="Subtotal"

assert aux ==1 if Port =="Subtotal"
drop aux

assert inlist(Reg,"PATAGONIA","NEA","NOA","CENTRO") in 1/`=_N-1'
assert Reg =="Total AP" in L

assert Port =="Total"  | Port =="Subtotal" | (Port =="Total AP" in L)

assert Clasif_Port =="UNIPORT"  | Clasif_Port =="MULTIPORT" |                     ///
(Clasif_Port =="Total AP" in L)

assert Acceso =="COBRA"  | Acceso =="NO COBRA" | (Acceso=="Total AP" in L)
assert AP_Separador == AP if Port=="Total"
assert AP_Separador == AP_Separador[_n-1] if Port=="Subtotal"
assert AP_Separador == "Total AP" in L

*Comprueba que no haya meses missing
forval i = 1/12 {
    foreach j in ext nacmay rprov rloc est jp men total nactotal {
	assert m`i'_2018`j'!=. 
	}
}
	
*Comprueba trimestres, semestres y total anual
foreach i in ext nacmay rprov rloc est jp men total nactotal {
    assert trim1_2018`i' == m1_2018`i' + m2_2018`i' + m3_2018`i'  
    assert trim2_2018`i' == m4_2018`i' + m5_2018`i' + m6_2018`i' 
    assert trim3_2018`i' == m7_2018`i' + m8_2018`i' + m9_2018`i'
    assert trim4_2018`i' == m10_2018`i' + m11_2018`i' + m12_2018`i'
    assert sem1_2018`i' == trim1_2018`i' + trim2_2018`i' 
    assert sem2_2018`i' == trim3_2018`i' + trim4_2018`i'
    assert total_2018`i' == sem1_2018`i' + sem2_2018`i'
}

local foo = 1 
*Confirma acumulados
forval i = 2/12 {
    foreach k in ext nacmay rprov rloc est jp men total nactotal {
        assert ac`i'_2018`k' >= ac`foo'_2018`k'
	 assert ac12_2018`k' == total_2018`k'
        }
 local foo = `foo' + 1
}

*Confirma trimestres y semestres contra acumulados
foreach i in ext nacmay rprov rloc est jp men total nactotal {
    assert trim1_2018`i'== ac3_2018`i'
    assert trim2_2018`i'== ac6_2018`i'-trim1_2018`i'
    assert trim3_2018`i'== ac9_2018`i'-trim1_2018`i'-trim2_2018`i'
    assert trim4_2018`i'== ac12_2018`i'-trim1_2018`i'-trim2_2018`i'-trim3_2018`i'
    assert sem1_2018`i'== ac6_2018`i'
    assert sem2_2018`i'== ac12_2018`i'-sem1_2018`i'
}

*Confirma total nacionales
assert total_2018nactotal == total_2018total - total_2018ext
assert total_2018nactotal== ac12_2018nactotal

log close
exit
