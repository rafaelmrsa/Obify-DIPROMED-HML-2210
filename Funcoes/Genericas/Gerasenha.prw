
//#INCLUDE"PROTHEUS10.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

*____________________________________________________________________________________________________________________________
/*
Programa: Gerasenha (Versao Beta) - Cria chaves para autorizacao de Emergencia

Desc: Caso a liberacao para o uso da empresa nao possa ser efetuada imediatamente, pode se recorrer a senha 
de emergencia. Esta senha e apenas temporaria e tera validade apenas durante o dia em que foi digitada, 
ou seja, 24 horas.

Uso:P10

WFS 06/01/11
*/
*____________________________________________________________________________________________________________________________

User Function Gerasenha

Local _oDlg,oEdit1,oEdit2:=nil
local cMsg1:='Gerado arquivo _SENHAS.TXT'+CRLF+'em StartPath!'  //Usado no corpo da mensagem - funcao msgbox()
local cMsg2:='Autorizacao de Emergencia' //Usado no titulo do msgbox()

SET DATE FORMAT "dd/mm/yyyy"

Private cEdit1		:=date()
Private cEdit2		:=date()

private aListBox1	:={}
Private nLista		:=0

Private oMeter
Private nMeter		:=0

DEFINE MSDIALOG _oDlg FROM 0,0 TO 213,461 TITLE "Gerador - Autorizacao de Emergencia...";
Color CLR_BLACK,CLR_WHITE PIXEL

	// Painel Lado Esquerdo
	@  018 , 005  Say 		"De?" 			Size  012 , 008  COLOR CLR_BLACK 	PIXEL OF _oDlg
	@  035 , 005  Say 		"Até?" 			Size  013 , 008  COLOR CLR_BLACK 	PIXEL OF _oDlg
	@  016 , 020  MsGet	oEdit1 Var cEdit1 	Size  060 , 009  COLOR CLR_BLACK 	PIXEL OF _oDlg
	@  034 , 020  MsGet	oEdit2 Var cEdit2 	Size  060 , 009  COLOR CLR_BLACK 	PIXEL OF _oDlg
	@  052 , 005  Button	"Processar..." 	Size  075 , 025 action Processar()  PIXEL OF _oDlg
	
	//Painel lado direito
	@3,90 ListBox oListBox1 Var nLista  Items aListBox1 Pixel Size 137,75 of _oDlg
	oListBox1:setArray(aListBox1)
	
	//Rodape
	oMeter:= tMeter():New(90,04,{|u|if(Pcount()>0,nMeter:=u,nMeter)},137,_oDlg,142,10,,.T.) // cria a régua
	
	@ 84,03 TO 85, 228  OF _oDlg PIXEL
	
	oExporta	:= TButton():New(89,149,'Exportar...',_oDlg,{||	MsgRun("Favor Aguardar.....", "Exportando os Registros...",{||Exporta(aListBox1)}),MSGALERT(cMsg1,cMsg2)},37,12,,,,.T.);oExporta:SetCss("QPushButton{}")
	oSair	:= TButton():New(89,191,'Sair',_oDlg,{||_oDlg:end()},37,12,,,,.T.);oSair:SetCss("QPushButton{}")
	
	oExporta:disable()
	oMeter:Hide()

ACTIVATE MSDIALOG _oDlg CENTERED

Return

*_____________________________________________________________________________________________________________________

static function Processar()

local _dData:=cEdit1
	
aListBox1:={}
	
IIF((cEdit2-_dData)>0,oMeter:NTOTAL:=(cEdit2-_dData),)
oMeter:Set(0)							// inicia a régua
oMeter:SHOW()

oExporta:disable()
	
	While _dData<=cEdit2
		
		ProcessMessages() 					// atualiza a pintura da janela, processa mensagens do windows
		nCurrent:= Eval(oMeter:bSetGet) 	// pega valor corrente da régua
		nCurrent++							// atualiza régua
		oMeter:Set(nCurrent)
	
		cChave:=Gera(_dData)
		
		aAdd(aListBox1,dtoc(_dData)+' - '+cChave)
		oListBox1:setArray(aListBox1)
		oListBox1:refresh()
		
		_dData++
	
	Enddo
	
	nCurrent:= Eval(oMeter:bSetGet) // pega valor corrente da régua
	nCurrent++
	oMeter:Set(nCurrent)
	oMeter:Hide()
	
	if !empty(aListBox1)
		oExporta:Enable()
	endif
	
Return

*_____________________________________________________________________________________________________________________

Static function  Gera(_dData)

local _cSenha,nValidaData,nValidaChave
Default _dData:= dDatabase

	//Processa
   
	nValidaData		:=	(_ddata-ctod('01/01/50'))
	nValidaChave	:=	round(NValidaData*5,0)
	nValidaChave 	:=	round((nValidaChave%867+nValidaChave%134),0)
	_cSenha 		:=	cValtochar(nValidaData)+cValtochar(nValidaChave)
	
	//Embaralha
	_cSenha			:=	Subs(_cSenha,1,1)+Subs(_cSenha,7,1)+;
					    Subs(_cSenha,4,1)+Subs(_cSenha,8,1)+;
						Subs(_cSenha,3,1)+Subs(_cSenha,5,1)+;
						Subs(_cSenha,6,1)+Subs(_cSenha,2,1)
Return(_cSenha)

*_____________________________________________________________________________________________________________________

Static function  Exporta(aItens)
Local cTexto
local cMensagem:=''

	cTexto:='Autorizacao de Emergencia'+CRLF
	cTexto:='Data Base  - Chave'+CRLF	

	For nX:=1 to len(aItens)
        	cTexto+=aItens[nX]+CRLF
	Next
    
   	Memowrite('_SENHAS.TXT',cTexto)
	
Return
