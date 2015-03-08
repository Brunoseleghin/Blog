#include "protheus.ch"

/* ====================================================================
Fun��o     U_TSTDBIMG
Autor      J�lio Wittwer
Vers�o     1.150308
Data       27/02/2015
Descri��o  Fun��o de teste da classe ApDBImage, para lidar com imagens
armazenadas no Banco de Dados

Refer�ncias

http://tdn.totvs.com/display/tec/Como+alinhar+controles+em+uma+janela
http://tdn.totvs.com/display/tec/cGetFile

Alinhamento de componentes de interface

CONTROL_ALIGN_ALLCLIENT  // Alinha preenchendo todo o conte�do da Janela ou Painel onde estiver
CONTROL_ALIGN_TOP        // Alinha ao Topo
CONTROL_ALIGN_BOTTOM     // Alinha ao Rodap�
CONTROL_ALIGN_LEFT       // Alinha � Esquerda
CONTROL_ALIGN_RIGHT      // Alinha � Direita
CONTROL_ALIGN_NONE       // N�o utiliza alinhamento

==================================================================== */

// Imagem atual mostrada na interface
STATIC _cImageName := ""
STATIC _nImageFrom := 0
STATIC _oBmp
STATIC _oScroll

User Function TSTDBIMG()
Local oDBImg

/*
If MsgYesNo("apaga banco de imagens")
	tcLink("MSSQL/STRESS","localhost",7890)
	tcdelfile("ZDBIMAGE")
Endif
*/

// Informa para a interface o tema DEFAULT
PTSetTheme("OCEAN")

// Cria uma inst�ncia do Manager de Imagens
oDBImg := APDBIMAGE():New()

// Inicializa a inst�ncia para uso
// Voc� j� deve estar conectado no DBACcess

If !oDBImg:Open()
	MsgStop(oDBImg:cError,"Falha ao iniciar")
	Return
Endif

DEFINE DIALOG oDlg TITLE "Exemplo de Imagem no SGDB" FROM 0,0 TO 600,800 PIXEL

// Cria um painel para os bot�es de a��es
// e Alinha o painel � esquerda
@ 0,0 MSPANEL oPanelMenu RAISED SIZE 90,1 OF oDlg
oPanelMenu:align := CONTROL_ALIGN_LEFT

// Cria um scroll para conter a imagem 
@ 0,0 SCROLLBOX _oScroll HORIZONTAL VERTICAL SIZE 10, 10 OF oDlg
_oScroll:align := CONTROL_ALIGN_ALLCLIENT

// Cria o bot�o para carregar imagem do disco

@ 10,05 BUTTON oButton1 PROMPT "Ler do &Disco" ;
	ACTION (LoadFromDSK()) SIZE 080, 15 of oPanelMenu  PIXEL

@ 30,05 BUTTON oButton1 PROMPT "Ler do &RPO" ;
	ACTION (LoadFromRPO()) SIZE 080, 15 of oPanelMenu  PIXEL

@ 50,05 BUTTON oButton1 PROMPT "Ler do DB&IMAGE" ;
	ACTION (LoadFromDBI(oDBImg)) SIZE 080, 15 of oPanelMenu  PIXEL

@ 70,05 BUTTON oButton2 PROMPT "&Salvar em Disco" ;
	ACTION (SaveToDisk(oDBImg)) SIZE 080, 15 of oPanelMenu  PIXEL

@ 90,05 BUTTON oButton1 PROMPT "I&nserir no DBIMAGE" ;
	ACTION (InsertDBImg(oDBImg)) SIZE 080, 15 of oPanelMenu  PIXEL

@ 110,05 BUTTON oButton1 PROMPT "&Alterar o DBIMAGE" ;
	ACTION (UpdDBImg(oDBImg)) SIZE 080, 15 of oPanelMenu  PIXEL

@ 130,05 BUTTON oButton1 PROMPT "Apaga&r do DBIMAGE" ;
	ACTION (DelDBImg(oDBImg)) SIZE 080, 15 of oPanelMenu  PIXEL

@ 150,05 BUTTON oButton1 PROMPT "Es&tat�sticas DBIMAGE" ;
	ACTION (DBImgStat(oDBImg)) SIZE 080, 15 of oPanelMenu  PIXEL

ACTIVATE DIALOG oDlg CENTER

// Fecha o DBImage
oDBImg:Close()

Return


/* --------------------------------------------------------
Le uma imagem ( bmp / jpg / png ) do disco e coloca na tela
A Leitura � feita direto pelo objeto de interface tBitmap())
-------------------------------------------------------- */
STATIC Function LoadFromDSK()
Local cImgFile := ''
Local cImgType := ''

cImgFile := cGetFile("ahbahba","*.bmp;*.png",0,"\",.F., NIL ,.T.)

If !empty(cImgFile)
	
	// Verifica se o tipo do arquivo � suportado 
	// -- avalia pela extens�o 
	If !ImgFileType( cImgFile , @cImgType )
		msgStop("Arquivo ["+cImgFile+"] n�o suportado.")
		Return
	Endif
	
	// Mostra a imagem (aqruivo) na interface	
	DisplayBmp(cImgFile,.T.)
	
	// Imagem carregada do disco
	_cImageName := cImgFile
	_nImageFrom := 1

Endif

Return

/* --------------------------------------------------------
Le uma imagem gravada como resorce do RPO
Deve ser informado o nome do resource a ser carregado
O proprio componente de interface faz a carga
-------------------------------------------------------- */
STATIC Function LoadFromRPO()
Local cImgRes
Local cImgBuffer
Local cImgType

cImgRes := AskUser("Abrir imagem do RPO","Resource")

If !empty( cImgRes )

	If !LoadRes(cImgRes,@cImgType,@cImgBuffer)
		MsgStop("Resource ["+cImgRes+"] n�o encontrado.","LoadFromRPO")
		Return .F.
	Endif

	// Mostra a imagem (resource) na interface	
	DisplayBmp(cImgRes+'.'+cImgType , .F. )

	// Imagem carregada direto do RPO
	_cImageName := cImgRes
	_nImageFrom := 2
		
Endif

Return

/* --------------------------------------------------------
Carrega uma imagem do banco de dados
deve ser informado o ID da imagem
-------------------------------------------------------- */
STATIC Function LoadFromDBI(oDBImg)
Local cImgId
Local cImgBuffer := ''
Local cImgType := ''
Local cTmpFile := '\tmpimage.'

cImgId := AskUser("Abrir imagem do DBIMAGE","ImageId")

If !empty(cImgId)
	
	// Primeiro carrega do DBIMAGE
	If !oDBImg:ReadStr(cImgId,@cImgType,@cImgBuffer)
		MsgStop(oDBImg:cError,"LoadFromDBI")
		Return
	Endif
	
	// Imagem carregada do Banco na memoria
	// Agora salva em um arquivo temporario
	
	// A extensao do temporario deve ser o tipo da imagem
	cTmpFile += lower(cImgType)
	
	if file(cTmpFile)
		Ferase(cTmpFile)
	Endif

	// Salva a imagem no temporario do disco 	
	If !oDBImg:SaveTo( cTmpFile , cImgBuffer )
		MsgStop(oDBImg:cError,"LoadFromDBI")
		Return
	Endif

	// Mostra a imagem (arquivo) na interface	
	DisplayBmp( cTmpFile , .T. )

	// Imagem carregada da Tabela de Imagens 
	_cImageName := cImgId
	_nImageFrom := 3
	
Endif

Return


/* --------------------------------------------------------
Grava a imagem atualmente em foco no disco
-------------------------------------------------------- */
STATIC Function SaveToDisk(oDBImg)
Local cImgSave
Local cImgType := ''
Local cImgBuffer := ''

If empty( _cImageName )
	MsgInfo("Nao h� imagem na interface para salvar em disco.")
	Return
Endif

cImgSave := cGetFile(NIL,NIL,1,"\",.T., NIL ,.T.)

If empty(cImgSave)
	Return
Endif

If !LoadCurrentImage(oDBImg,@cImgBuffer,@cImgType)
	Return
Endif

If !"."$cImgSave
	cImgSave += ("." + cImgType )
Endif

If !file(cImgSave) .or. MsgYesNo("Arquivo ["+cImgSave+"] j� existe. Sobrescrever ? ")

	// Se vai gravar e o arquivo j� existe, apaga
	If file(cImgSave)
		ferase(cImgSave)
	Endif
	
	// Apos a imagem estar na memoria, salva em disco
	If !oDBImg:SaveTo(cImgSave,cImgBuffer)
		MsgStop(oDBImg:cError,"SaveToDisk")
		Return
	Endif
	
	MsgInfo("Arquivo ["+cImgSave+"] salvo.")
	
Endif

Return

/* --------------------------------------------------------
Insere a imagem em foco no Database
-------------------------------------------------------- */
STATIC Function InsertDBImg(oDBImg)
Local cImgId
Local cImgBuffer := ''
Local cImgType

If empty( _cImageName )
	MsgInfo("Nao h� imagem na interface para inserir.")
	Return
Endif

cImgId := AskUser("Inserir no ImageID","ID da Imagem",_cImageName)

If empty(cImgId)
	Return 
Endif	

// Carrega imagem corrente na memoria
If !LoadCurrentImage(oDBImg,@cImgBuffer,@cImgType)
	Return
Endif

// Salva imagem no DBImage, inserindo
If !oDBImg:Insert( cImgId , cImgType , cImgBuffer )
	MsgStop(oDBImg:cError,"InsertDBImg")
	Return
Endif

MsgInfo("ImageId ["+cImgId+"] inserida no DBImage.")

Return

/* --------------------------------------------------------
Atualiza / altera a imagem em foco no Database
Deve ser informado o ID da imagem do banco a ser alterado
-------------------------------------------------------- */
STATIC Function UpdDBImg(oDBImg)
Local cImgId
Local cImgBuffer := ''
Local cImgType := ''

If empty( _cImageName )
	MsgInfo("Nao h� imagem na interface para atualizar.")
	Return
Endif

cImgId := AskUser("Atualizar o ImageID","ID da Imagem",_cImageName)

If empty(cImgId)
	Return
Endif

// Carrega imagem corrente na memoria
If !LoadCurrentImage(oDBImg,@cImgBuffer,@cImgType)
	Return
Endif

// Atualiza imagem no DbImage	
If !oDBImg:Update( cImgId , cImgType, cImgBuffer )
	MsgStop(oDBImg:cError,"UpdateDBImg")
	Return
Endif
	
MsgInfo("ImageId ["+cImgId+"] atualizada no DBImage.")
	
Return

/* --------------------------------------------------------
Deleta uma imagem do banco de imagens
Deve ser informado o ID da imagem do Banco a ser apagada
-------------------------------------------------------- */
STATIC Function DelDBImg(oDBImg)
Local cImgId
Local cImgBuffer := ''

cImgId := AskUser("Apagar do ImageID","ID da Imagem",_cImageName)

If empty(cImgId)
	Return
Endif

// Apaga fisicamente imagem do DBimage	
If !oDBImg:Delete( cImgId )
	MsgStop(oDBImg:cError,"DelDBImg")
	Return
Endif
	
MsgInfo("ImageId ["+cImgId+"] apagada no DBImage.")

Return

/* --------------------------------------------------------
Mostra mensagem de estatisticas do banco de imagens
Monta im HTML monoespa�ado para ser mostrado pela fun��o MsgInfo()
-------------------------------------------------------- */
STATIC Function DBImgStat(oDBImg)
Local aStatus := {}
Local nI
Local cHtml := '<html><pre><hr>'

If !oDBImg:Status( @aStatus )
	MsgStop(oDBImg:cError,"DBImgStat")
	Return
Endif

For nI := 1 to len(aStatus)
	cHtml += padr(aStatus[nI][1],20,'.')+cValToChar(aStatus[nI][2]) + CRLF
Next

cHtml += '</pre></html>'

Return MSgInfo(cHtml,'DBI Status')

/* --------------------------------------------------------
Recebe cImgType por referencia (@)
Retorna .T. e preenche o cImgType caso o arquivo
tenha uma extensao suportada
-------------------------------------------------------- */
STATIC Function ImgFileType( cImgFile , /* @ */ cImgType )
Local cExt := ''
cImgType := ''
SplitPath(cImgFile,,,,@cExt)
If Upper('/'+cExt+'/')$'/.BMP/.PNG/.JPG/'
	cImgType := substr(cExt,2)
Endif
Return !Empty(cImgType)

/* --------------------------------------------------------
Recarrega a imagem atual na memoria para opera��es
como salvar em disco ou inserir / alterar na tabela de Imagens
-------------------------------------------------------- */
STATIC Function LoadCurrentImage(oDBImg,  /* @ */ cImgBuffer , /* @ */ cImgType )
Local nPos

cImgBuffer := ''
cImgType   := ''

If _nImageFrom == 1 
	
	// Le Arquivo do disco para a memoria
	// Usa metodo da DBImage para acesso a disco 
	If !oDBImg:LoadFrom( _cImageName , @cImgBuffer )
		MsgStop(oDBImg:cError,"LoadImage")
		Return .F. 
	Endif        
	      
	// O tipo da imagem � a extens�o do arquivo
	nPos := rat(".",_cImageName)
	If nPos > 0 
		cImgType := substr(_cImageName,nPos+1)
	Endif	

ElseIf _nImageFrom == 2
	
	If !LoadRes(_cImageName,@cImgType,@cImgBuffer)
		MsgStop("Resource ["+_cImageName+"] n�o encontrado.","LoadImage")
		Return .F.
	Endif

ElseIf _nImageFrom == 3
	
	// Carrega DBImage para a memoria
	If !oDBImg:ReadStr(_cImageName,@cImgType,@cImgBuffer)
		MsgStop(oDBImg:cError,"LoadImage")
		Return .F. 
	Endif

Else

	MsgStop("Nao h� imagem na interface.","LoadImage")	
	Return .F.
	
Endif

Return .T.
 
/* --------------------------------------------------------
Le resource do RPO para a memoria E identifica o tipo.
Deve receber apenas o nome do resource, sem extensao
-------------------------------------------------------- */
 
STATIC Function LoadRes(cResName , /*@*/ cImgType, /*@*/ cImgBuffer)
cImgBuffer := GETAPORES(cResName+'.BMP')
If !empty(cImgBuffer)
	cImgType := 'BMP'
Else
	cImgBuffer := GETAPORES(cResName+'.PNG')
	If !empty(cImgBuffer)
		cImgType := 'PNG'
	Else
		cImgBuffer := GETAPORES(cResName+'.JPG')
		If !empty(cImgBuffer)
			cImgType := 'JPG'
		Endif
	Endif
Endif
Return !empty(cImgType)


/* --------------------------------------------------------
Refefine o objeto de interface para mostrar 
a imagem na tela ( Resource ou Arquivo ) 
-------------------------------------------------------- */

STATIC Function DisplayBmp( cName , lFile )

If _oBmp != NIL
	// Se j� tinha uma imagem na interface, "fecha"
	FreeObj(_oBmp)
Endif

If lFile
	// Carga a partir de arquivo
	@ 0,0 BITMAP _oBmp  FILE (cName) SCROLL OF _oScroll PIXEL
Else
	// Carga a partir de resource no RPO 
	@ 0,0 BITMAP _oBmp  RESOURCE (cName) SCROLL OF _oScroll PIXEL
Endif

// Habilita a imagem para "se encaixar" na interface 
_oBmp:lAutoSize := .T.

Return

/* --------------------------------------------------------
Tela de interface para perguntar uma string ao usuario
Usada para pedir ID de imagem ou nome de resource
-------------------------------------------------------- */
STATIC Function AskUser(cTitle, cMessage , cRet )
Local oDlg
Local lOk  := .F.

If cRet == NIL
	cRet := space(30)
else
	cRet := padr( Upper(alltrim(cRet)) , 30 )
Endif

DEFINE DIALOG oDlg TITLE (cTitle) FROM 0,0 TO 60,340 PIXEL

@ 08,05 SAY oSay Prompt (cMessage) SIZE 40,13 OF oDlg PIXEL

@ 05,50 GET oGet VAR cRet PICTURE "@!" SIZE 80,13  OF oDlg PIXEL

DEFINE SBUTTON osBtn01  FROM 05 , 140  TYPE 01 ACTION ( lOk := .T. , oDlg:End() ) OF oDlg  ENABLE
DEFINE SBUTTON osBtn02  FROM 15 , 140  TYPE 02 ACTION ( lOk := .F. , oDlg:End() ) OF oDlg  ENABLE

ACTIVATE DIALOG oDlg CENTER

Return IIF( lOk , Alltrim(cRet) , '' )

