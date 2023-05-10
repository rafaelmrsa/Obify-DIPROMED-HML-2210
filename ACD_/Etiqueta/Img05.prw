/*
Padrao Zebra
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMG05     บAutor  ณEmerson Leal Bruno  บ Data ณ  07/09/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada referente a imagem de identificacao do     บฑฑ
ฑฑบ          ณvolume temporario                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Img05	   // imagem de etiqueta de volume temporaria
Local cVolume := paramixb[1]
Local cPedido := paramixb[2]
//Local cNota   := IF(len(paramixb)>=3,paramixb[3],nil)
//Local cSerie  := IF(len(paramixb)>=4,paramixb[4],nil)
//Local cID := CBGrvEti('05',{cVolume,cPedido,cNota,cSerie})
Local sConteudo                     
Local nCep       := ""
Local cTransp    := CB7->CB7_TRANSP
Private cFilUtil := ""

nCep := Posicione("SA1",1,xFILIAL("SA1")+CB7->CB7_CLIENT,"A1_CEPE") //VERIFICAR SE RETORNA ESSE OU A1_CEP

If CB7->CB7_TRANSP == "003025"   //RBorges 09/04/15 - Tratamento para Imprimir a rota da filial quando for Utilissimo
	u_xrotacep(nCep,cTransp)

	MSCBBEGIN(1,4)
	
	If cEmpAnt == "04" .And. !Empty(CB7->CB7_XREQMT)
		MSCBSAY(05,03,"Requisi็ใo:","N","C","30")
	Else
		MSCBSAY(05,03,"Pedido:","N","C","30")	
	EndIf
	
	MSCBSAY(42,02,cPedido,"N","C","60")
	MSCBSAY(80,02,cFilUtil,"N","C","60")	
	MSCBSAY(05,24,"O.S.:"+CB7->CB7_ORDSEP+" Volume:"+cVolume,"N","C","30")
	If (Len(Alltrim(CB7->CB7_XTOUM))) > 1	
		MSCBSAY(82,10,CB7->CB7_XTOUM,"N","C","60")		
	Else 
   		MSCBSAY(87,10,CB7->CB7_XTOUM,"N","C","65")
	EndIf		
	
	If (Len(Alltrim(CB7->CB7_XTOUM))) > 1
		MSCBSAY(85,17,CB7->CB7_XTM,"N","C","60") 
	EndIf
		
	MSCBSAYBAR(05,10,cVolume,'N','C',12,.F.,.F.,.F.,  ,4,3) //'B'
	MSCBInfoEti("VOL: "+AllTrim(cVolume),"VOLUME")
    sConteudo:=MSCBEND()
Else 
	MSCBBEGIN(1,4)
	//     LEFT/TOP 
	
	If cEmpAnt == "04" .And. !Empty(CB7->CB7_XREQMT)
		MSCBSAY(05,03,"Requisi็ใo:","N","C","30")
	Else
		MSCBSAY(05,03,"Pedido:","N","C","30")	
	EndIf	
		
	MSCBSAY(42,02,cPedido,"N","C","60")
//	MSCBSAY(05,03,"Volume:","N","C","30")
//	MSCBSAY(33,03,cVolume,"N","C","45")	
	MSCBSAY(05,24,"O.S.:"+CB7->CB7_ORDSEP+" Volume:"+cVolume,"N","C","30")
	If (Len(Alltrim(CB7->CB7_XTOUM))) > 1	
		MSCBSAY(82,10,CB7->CB7_XTOUM,"N","C","60")		
	Else 
   		MSCBSAY(87,10,CB7->CB7_XTOUM,"N","C","65")
	EndIf		
	
	If (Len(Alltrim(CB7->CB7_XTOUM))) > 1
		MSCBSAY(85,17,CB7->CB7_XTM,"N","C","60") 
	EndIf
		
	MSCBSAYBAR(05,10,cVolume,'N','C',12,.F.,.F.,.F.,  ,4,3) //'B'
	MSCBInfoEti("VOL: "+AllTrim(cVolume),"VOLUME")
    sConteudo:=MSCBEND()

EndIf
Return sConteudo 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMG05OFI  บAutor 				         บ Data ณ  19/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPonto de entrada referente a imagem de identificacao do     บฑฑ
ฑฑบ          ณvolume permanente."Oficial"                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ 		                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function Img05OFI // imagem de etiqueta de volume permanente (OFICIAL)

MSCBBEGIN(1,4)
	MSCBSAY(05,03,"Volume:","N","0","025,035")
	MSCBSAYBAR(05,12,cVolume,'N','C',12,.F.,.T.,.F.,  ,4,3) //'B'
	MSCBInfoEti("VOL: "+AllTrim(cVolume),"VOLUME")
MSCBEND()

Return .f.



// RBorges 09/04/15 - Com o Cep e a Transportadora do cliente, 
// buscar na tabela de rotas por cep a rota e a retorna para imprimir na etiqueta

User Function xRotaCep(nCepCli,cTrpCli)

Local QRY1     := ""  

QRY1 := "SELECT ZV_NUMROTA, ZV_SGFILIA, ZV_CLASSIF, ZV_SEQUEN"
QRY1 += " FROM " + RetSQLName("SZV")
QRY1 += " WHERE ZV_FILIAL = '"+xFilial("SZV")+"' " 
QRY1 += " AND ZV_TRANSP   = '"+cTrpCli+ "' "
QRY1 += " AND ZV_CEPINI  <= '"+nCepCli+ "' "
QRY1 += " AND ZV_CEPFIM  >= '"+nCepCli+ "' "

QRY1 += " AND D_E_L_E_T_ = ' ' "
QRY1 += " ORDER BY ZV_ROTA"

QRY1 := ChangeQuery(QRY1)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,QRY1),"QRY1",.T.,.T.) 


If !QRY1->(Eof())
	cFilUtil := QRY1->ZV_NUMROTA
EndIf

QRY1->(dbCloseArea())	      
	

Return(cFilUtil)
