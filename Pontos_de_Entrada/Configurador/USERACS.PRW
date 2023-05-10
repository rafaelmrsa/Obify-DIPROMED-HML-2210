#Include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณ USERACS  บ Autor ณ   Alexandro Dias   บ Data ณ  23/08/01     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDescricao ณ Inclui automaticamente os usuarios cadastrados na tabela de  บฑฑ
ฑฑบ          ณ operadores (SU7).                                            บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function USERACS()

Local _xAlias     := GetArea()
U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU
IF ParamIxb[4] == "INCLUI"
	IF MsgBox("Deseja incluir este usuario no cadastro de Operadores do Fat/Tmk","Atencao","YESNO")
		RecLock("SU7",.T.)
		Replace U7_FILIAL With xFilial("SU7")
		Replace U7_COD    With GetSx8Num("SU7","U7_COD")
		ConfirmSx8()
		Replace U7_NOME    With Upper(ParamIxb[1])
		Replace U7_NREDUZ  With Upper(ParamIxb[1])
		Replace U7_POSTO   With "01"
		Replace U7_VEND    With '1'
		Replace U7_TIPOATE With '4'
		MsUnLock()
	EndIF
EndIF

RestArea(_xAlias)

Return(Space(10))