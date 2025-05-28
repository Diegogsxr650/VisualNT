SET DATE TO GERMAN
SET SAFETY OFF
SET PATH TO "C:\temp\PracticaSanAndres"

CLEAR

*-- Clase Exportadora
DEFINE CLASS ExportadorJSON AS Custom

    PROCEDURE Exportar(tcTabla, tcFicheroSalida)
        LOCAL lnHandle, lcLinea, lnReg, lcCampo, lcValor, i, lnCampos
        LOCAL lcJSON, lcNombreTabla, lcLineaId, lcTipoCampo

        IF !FILE(tcTabla)
            ? "No se encuentra la tabla: " + tcTabla
            RETURN .F.
        ENDIF

        USE (tcTabla) IN 0 ALIAS MiTabla SHARED
        SELECT MiTabla
        INDEX ON documento TAG documento
        SET ORDER TO documento

        *-- Eliminar fichero si ya existe
        IF FILE(tcFicheroSalida)
            ERASE (tcFicheroSalida)
        ENDIF

        *-- Crear fichero de salida
        lnHandle = FCREATE(tcFicheroSalida)
        IF lnHandle < 0
            ? "No se pudo crear el fichero de salida. Error de sistema: " + SYS(2023)
            RETURN .F.
        ENDIF

        *-- Nombre de la tabla sin extensión
        lcNombreTabla = JUSTSTEM(tcTabla)
        lcJSON = '{' + CHR(13) + ;
                 '  "tabla": "' + lcNombreTabla + '",' + CHR(13) + ;
                 '  "lineas": {' + CHR(13)

        lnReg = 0
        SCAN
            lnReg = lnReg + 1
            lcLinea = '    "' + TRANSFORM(lnReg) + '": {' + CHR(13)

            lnCampos = FCOUNT()
            FOR i = 1 TO lnCampos
                lcCampo = FIELD(i)
                lcTipoCampo = TYPE(lcCampo)

                DO CASE
                    CASE lcTipoCampo = "C"  && Caracter
                        lcValor = '"' + STRTRAN(ALLTRIM(EVALUATE(lcCampo)), '"', '\"') + '"'
                    CASE lcTipoCampo = "N"  && Numérico
                        lcValor = TRANSFORM(EVALUATE(lcCampo))
                    CASE lcTipoCampo = "D"  && Fecha
                        lcValor = '"' + DTOC(EVALUATE(lcCampo)) + '"'
                    CASE lcTipoCampo = "M"  && Memo
                        lcValor = '"' + STRTRAN(ALLTRIM(EVALUATE(lcCampo)), '"', '\"') + '"'
                    CASE lcTipoCampo = "L"  && Lógico
                        lcValor = IIF(EVALUATE(lcCampo), "true", "false")
                    OTHERWISE
                        lcValor = '""'
                ENDCASE

                *-- Añadir campo a la línea
                lcLinea = lcLinea + '      "' + lcCampo + '": ' + lcValor
                IF i < lnCampos
                    lcLinea = lcLinea + ',' + CHR(13)
                ELSE
                    lcLinea = lcLinea + CHR(13)
                ENDIF
            ENDFOR

            lcLinea = lcLinea + '    }'

            IF !EOF()
                lcLinea = lcLinea + ',' + CHR(13)
            ELSE
                lcLinea = lcLinea + CHR(13)
            ENDIF

            lcJSON = lcJSON + lcLinea
        ENDSCAN

        lcJSON = lcJSON + '  }' + CHR(13) + '}'

        *-- Escribir contenido
        =FPUTS(lnHandle, lcJSON)
        =FCLOSE(lnHandle)

        ? "Exportación finalizada correctamente."
        RETURN .T.
    ENDPROC

ENDDEFINE

*-- Crear instancia y ejecutar
oExportador = NEWOBJECT("ExportadorJSON")
oExportador.Exportar("movimien.dbf", "C:\temp\PracticaSanAndres\movimien.json")
