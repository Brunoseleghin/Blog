/* ------------------------------------------------------------
Funcao 		    U_GetSCR()
Autor					J�lio Wittwer
Data					09/2016
Descri��o			Tira um ScreenShot da tela da m�quina onde est� 
							sendo executado o TOTVS | SmartClient, e copia 
							o JPEG com a imagem gerada para uma pasta 
							chamada "\images\" a partir do RootPath do 
							ambiente no Servidor
Observa��o	  A Pasta \images\ a partir do RootPath deve ser 
							criada antes de executar este programa

------------------------------------------------------------ */

User function GetSCR()

Local hHdl := 0
Local cRet
Local nCode
Local cRmtFile
Local cSrvFile 
Local cImgFile

// Abre a DlL
hHdl := ExecInDLLOpen( "GetScreen.dll" )

IF hHdl == -1 
	UserException("Failed to load [GetScreen.dll]")
Endif

// Pega a versao do GetScreen
cRet := ExecInDllRun( hHdl, 0, "" )
conout(cRet)

// identifica a pasta temporaria da maqina 
// que est� rodando o smartclient 
// e usa ela pra criar a imagem do screenshot

cImgFile := 'img_'+cValTochar(Threadid())+'.jpeg'
cRmtFile := GETTEMPPATH() + cImgFile;

Msgrun(	"Aguarde",;
				"Executando captura de tela",;
				{|| cRet := ExecInDllRun( hHdl, 1, padr(cRmtFile,200))}	 )


If empty(cRet)
	UserException("Unexpected Empty result from [GetScreen.dll]")
Endif

// Verifica o codigo retornado
// 000 = Sucesso 
// <> 0 = Falha

nCode := val(left(cRet,3))
If nCode > 0 
	UserException(cRet)
Endif

// copia o arquivo do terminal para o servidor
CPYT2S(cRmtFile,"\images\")

// Apaga o arquivo na pasta tempor�ria da esta��o 
Ferase(cRmtFile)

// Informa a opera��o realizada
MsgInfo("Imagem salva no servidor em \images\"+cImgFile)

// ----------------------------------------------------------------
// Fecha a DLL
ExecInDllClose( hHdl )

Return                     

