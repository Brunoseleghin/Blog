#include 'protheus.ch'

/* =================================================================================

Fun��es de Processamento AdvPL ASP 

U_ASPInit -- Responsavel por inicializar uma Working Thread do Pool de Processos 
U_ASPConn -- Responsavel por atender a uma requisi��o de link .apw vinda do Browser

================================================================================= */

User Function ASPInit()
Local nTopHnd

SET DATE BRITISH
SET CENTURY ON 

nTopHnd := TCLInk()

If nTopHnd < 0 
	ConsoleMsg("ASPINIT - Falha de conex�o "+cValToChar(nTopHnd))
	Return .F.
Endif

SET DELETED ON 

ConsoleMsg("ASPINIT - Thread Advpl ASP ["+cValToChar(ThreadID())+"] Iniciada")

Return .T.

// ---------------------------------------------------------------------------------

USER Function ASPConn()
Local cReturn := ''
Local cAspPage 
Local nTimer

cAspPage := HTTPHEADIN->MAIN

If !empty(cAspPage)

	nTimer := seconds()
	cAspPage := LOWER(cAspPage)
	ConsoleMsg("ASPCONN - Thread Advpl ASP ["+cValToChar(ThreadID())+"] Processando ["+cAspPage+"]")

	do case 
	
	case cAspPage == 'index'
		// Execura a p�gina INDEX.APH compilada no RPO 
		// A String retornada deve retornar ao Browser
		cReturn := H_INDEX()
	case cAspPage == 'login'
		// Realiza login de usu�rio
		cReturn := U_WLOGIN()
	case cAspPage == 'logoff'
		// Realiza logoff de usu�rio
		cReturn := U_WLOGOFF()
	case cAspPage == 'agenda'
		// Executa a agenda em AdvPL ASP 
		// Os controles e p�ginas est�o encapsulados pela fun��o U_WAgenda()
		cReturn := U_WAGENDA()
	case cAspPage == 'getinfo'
	    // Executa a pagina GetInfo.APH
	    cReturn := H_GETINFO()
	case cAspPage == 'headinfo'
	    // Executa a pagina HeadInfo.APH
	    cReturn := H_HEADINFO()
	case cAspPage == 'formpost'
	    // Executa a pagina FormPost
	    cReturn := H_FORMPOST()
	case cAspPage == 'postinfo'
	    // Executa a pagina PostInfo
	    cReturn := H_POSTINFO()
	case cAspPage == 'aspinfo'
	    cReturn := H_ASPINFO()
	otherwise
		// retorna HTML para informar 
		// a condi��o de p�gina desconhecida
		cReturn := "<html><body><center><b>P�gina AdvPL ASP ["+cAspPage+"] n�o encontrada.</b></body></html>"
	Endcase

	nTimer := seconds() - nTimer
	ConsoleMsg("ASPCONN - Thread Advpl ASP ["+cValToChar(ThreadID())+"] Processamento realizado em "+ alltrim(str(nTimer,8,3))+ "s.")

Else

	cReturn := "<html><body><center><b>Requisi��o AdvPL ASP Inv�lida.</b></body></html>"

Endif

Return cReturn


// ---------------------------------------------------------------------------------
// Funcao de mensagem de console
// Registra data e hora da requisi��o, com a mensagem informada
// ---------------------------------------------------------------------------------

STATIC Function ConsoleMsg(xMsg)
Local nSecs := seconds()
nSecs := (nSecs - int(nSecs))*1000
conout("["+dtos(date())+"|"+time()+"."+strzero(nSecs,3)+"] "+cValToChar(xMsg))
return

