/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA010MNU �Autor  �Maximo Canuto       � Data �  12/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � P.E. chamado na cria��o do menu no mata010, permite alterar���
���          � o aRotina                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
#INCLUDE "MATA010.CH"
#INCLUDE "PROTHEUS.CH"

User Function MTA010MNU()
Local _xAlias   := GetArea()
Local _areaSB1 := SB1->(getarea())                                                    

U_DIPPROC(ProcName(0),U_DipUsr()) // JBS 05/10/2005 - Gravando o nome do Programa no SZU

If !lIntLox
	aRotina	:= { 	{ OemToAnsi("Pesquisar") ,"AxPesqui"		, 0 , 1, 0, .F.},;		//"Pesquisar"
		{ OemtoAnsi("Visualizar") ,"A010Visul"		, 0 , 2, 0, nil},;				//"Visualizar"
		{ OemtoAnsi("Incluir") ,"A010Inclui"		, 0 , 3, 0, nil},;	  			//"Incluir"
		{ OemtoAnsi("Alterar") ,"U_AltDelSB1"		, 0 , 4, 2, nil},; 			   //"Alterar"
		{ OemtoAnsi("Excluir") ,"U_AltDelSB1	"	, 0 , 5, 1, nil},;			   //"Excluir"
		{ OemtoAnsi("Consulta") ,"A010Consul"		, 0 , 2, 0, .F.},;		      //"Consulta"
		{ OemtoAnsi("Copia"	) ,"A010Copia"		, 0 , 4, 0, nil}}             //"Copia"	
Else
	aRotina	:= { 	{ OemToAnsi("Pesquisar") ,"AxPesqui"		, 0 , 1, 0, .F.},;		//"Pesquisar"
		{ OemtoAnsi("Visualizar") ,"A010Visul"		, 0 , 2, 0, nil},;				//"Visualizar"
		{ OemtoAnsi("Alterar") ,"A010Altera"		, 0 , 4, 2, nil},; 			   //"Alterar"
		{ OemtoAnsi("Consulta") ,"A010Consul"		, 0 , 2, 0, .F.}}		      //"Consulta"
Endif
aAdd(aRotina,{OemtoAnsi("Facilitador")	,"A010WizFac"	, 0, 4, 2, .F.})	//"Facilitador"

aAdd(aRotina,{"Solicita Cx.Fech."	,"u_Dip071Avl"	, 0, 4, 2, .F.})
aAdd(aRotina,{"Avalia Cx.Emb."		,"u_DIPA071"	, 0, 4, 2, .F.})
aAdd(aRotina,{"Desbloqueia Cx.Emb."	,"u_D071Desb"	, 0, 4, 2, .F.})
aAdd(aRotina,{"Alternativos"		,"A010ProdAl"	, 0, 4, 2, .F.})  //"Alternativos" |Felipe Duran 04/10/19|

RestArea(_areaSB1)
RestArea(_xAlias)              

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AltDelSB1 �Autor  �Maximo Canuto       � Data �  12/05/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o chamada no aRotina do Mata010 para alterar produtos ���
���          � N�o Permite manuten��o se o produto veio da HQ-Matriz      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function AltDelSB1(cAlias,nReg,nOpc)

/*If cEmpAnt+cFilAnt <> '0401' .And. SB1->B1_PROC $ '051508' .AND. SB1->B1_LOJPROC = '27' .And. !('DIPM_B1' $ FUNNAME()) .And. (Type("l010Auto")=="U".Or.!l010Auto) .And. !AllTrim(Upper(U_DipUsr()))$'MCANUTO' 
	Alert("Manuten��o neste produto somente pode ser efetuado pela empresa HEALTH QUALITY - MATRIZ !!!")
	Return(.F.)
Else
*/
If nOpc == 4    
	If cEmpAnt+cFilAnt == "0101" .And. !(Upper(u_DipUsr())$Upper(GetNewPar("ES_USRFISC",""))) .And. (Type("l010Auto")=="U".Or.!l010Auto) 
		Aviso("Aten��o","Altera��o permitida somente na empresa DIPROMED CD",{"Ok"},1)
		Return	
	Else
		A010Altera(cAlias,nReg,nOpc)		
	EndIf
Else
	Mata010Deleta(cAlias,nReg,nOpc)
Endif

Return