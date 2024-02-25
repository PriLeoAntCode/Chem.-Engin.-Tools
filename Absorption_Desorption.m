%{
- Título / Title: 
     Desarrollo de Procesos de Absorción y Desorción en Columnas de Platos / Development of Absorption and Desorption Processes in Plates Columns
- Fecha de Creación / Creation Date: 
     24 de enero de 2024 / January 24th, 2024
- Fecha de Última Edición / Last Edition Date:
     07 de febrero de 2024 / February 07th, 2024
- Creado por / Created by:
     Priscilla Guerrero
- Institución / Institution:
     Ingeniería Química - Universidad Nacional de Colombia / Chemical Engineering - National University of Colombia

- Descripción: Este código en lenguaje MatLab permite resolver sistemas de absorción y desorción ejecutados en columnas de platos, permitiendo conocer 
     si la operación a las condiciones establecidas es posible, cuál será el flujo mínimo de fluido de separación y qué número de platos se requerirá 
     para poderse realizar. La nomenclatura que se maneja en este planteamiento corresponde a que una sustancia de interés, i, se encuentra en un flujo 
     líquido (X) o gaseoso (Y) A y será retirada por un flujo de la otra naturaleza B, compuestos ambos mayormente por una especie inerte s.

- Instrucciones: Debes ingresar la siguiente información en la respectiva sección del código, debajo de esta descripción, para proceder a la ejecución del 
     código:
     - Operación: Absorción o desorción.
     - Condiciones de Trabajo: Debes ingresar flujos de Entrada y Salida de la Corriente A y concentraciones y factor de operación de la corriente B.
     - Equilibrio: El código emplea para el equilibrio un conjunto de datos. Si tienes los datos experimentales o modelados debes agregarlos en los 
          respectivos vectores. Si dispones de una ecuación modelo (De la forma Y = f(X) o Y = f(X, T) a T constante), puedes introducirla y el código 
          obtendrá un conjunto de datos para trabajar con él.
     
- Description: This MatLab code allows to solve liquid-liquid extraction systems using equilibrium data and the algoritms of Parallel Flow and Counterflow
     working units. It's required to put here in the code the equilibrium data and the compositions of the problem mix feed, the solvent feed and the
     operation way (Parallel flow or Counterflow). Also, it will be required to give the desired final concentration OR the numbers of stages that
     are required to the system. The nomenclature of the substances is A: Initial Solvent, B: Extraction Solvent and C: Interest Substance to be Extracted.

%}

clear

% INGRESO DE INFORMACIÓN / INFORMATION INPUT:
     % 1. Operación / Operation:
     Oper = "Absorption";
     %Oper = "Desorption";
     
     % 2. Condiciones de Operación / Operation Conditions:
     switch(Oper)
         case "Absorption"
         % Required to Input:
         G1 = 110; G2 = 101; GS = 100; Gi1 = 10; Gi2 = 1; % Flujos de Gas / Gas Flows
         X2i = 0.005; % Concentración Inicial de Flujo Líquido / Liquid Flow Initial Concentration
         aFlujMin = 1.5; % Factor de Operación para Flujo Líquido Mínimo / Operation Factor for Minimum Liquid Flow
         % Automatic Calculation:
         Y1i = Gi1 / G1; Y2i = Gi2 / G2; % Concentraciones de Gas / Gas Concentrations
    
         case "Desorption"
         % Required to Input:
         L1 = 101; L2 = 110; LS = 100; Li1 = 1; Li2 = 10; % Flujos de Líquido / Liquid Flows 
         Y1i = 0.001; % Concentración Inicial de Flujo de Gas / Gas Flow Initial Concentration
         aFlujMin = 1.1; % Factor de Operación para Flujo de Gas Mínimo / Operation Factor for Minimum Gas Flow
         % Automatic Calculation:
         X1i = Li1 / L1; X2i = Li2 / L2; % Concentraciones de Líquido / Liquid Concentrations
     
     end 
     
     % 3. Equilibrio / Equilibrium:
     DataWay = "ByFunction";
     %DataWay = "ByData";
     
     switch(DataWay)
         case "ByFunction"
          % Example of Function Input:
          TOp = 15; % °C
          POp = 2; % Bar
          %FunEq = @(X, T, P) 0.0025 * X .^ 0.5 + (T * 0 + P * 0); % Y = f(X)
          FunEq = @(X, T, P) -2.0385 * (X * (0.0365 * T - 0.138)) .^ 2 + 2.9391 * X * (0.0364 * T - 0.1318) + (P * 0); % Y = f(X, T)
          %FunEq = @(X, T, P) 0.7 * X + T/500 - P / 1000; % Y = f(X, T, P)
          XEQ = linspace(0, 1, 10); YEQ = FunEq(XEQ, TOp, POp);
          
         case "ByData"
          % Example of Data Input:
          XEQ = [0.0000 0.1111 0.2222 0.3333 0.4444 0.5556 0.6667 0.7778 0.8889 1.0000];
          YEQ = [0.0300 0.1078 0.1856 0.2633 0.3411 0.4189 0.4967 0.5744 0.6522 0.7300];
     end

 % DESARROLLO DE LA OPERACIÓN:
 
 %{
     Descripción del Procedimiento: 
          1. Determinar flujo mínimo de solvente
               1a. Calcular los diferenciales de los datos empleados y usar como referencia de pendiente el valor más alto.
               1b. Establecer condiciones para iniciar ciclo de determinación de pendiente, cambiando valores para rotar tanto hacia arriba ("Pos") como
                    hacia abajo ("Neg").
               1c. Determinar las posibles rectas empleando la pendiente del Paso 1a y la coordenada 2 (Superior, con salida de gas e ingreso de líquido).
               1d. Realizar una evaluación de que a) Todos los puntos de la línea operatoria se encuentren encima (Sean mayores) que los de equilibrio Y
                    b) Haya una diferencia mínima por algún punto (Corte tangente) menor a una tolerancia dada entre las dos curvas. 
                         Si se cumple lo esperado, se llenará con 1s un vector compuesto por 0s que permitirá ser tomado como una señal, así como también se
                    guardará el valor de la pendiente. En caso de que no se cumpla, se aumenta el valor absoluto de la pendiente (O sea, para revisar por
                    arriba y por abajo) en un valor pequeño para seguir evaluando.
               1e. Se revisa que el valor de la pendiente es apropiado si hay un vector completo de 1s, para finalizar el ciclo. 
               1f. Se repite el ciclo desde el Paso 1c con los valores modificados de las pendientes desde el Paso 1d. Adicionalmente, se cuentan los intentos
                    realizados y se determina si la operación es viable al revisar si el equilibrio lo permite.
          2. En caso de que la operación sea viable, determinar flujo de operación de solvente.
          3. Caracterizar la corriente líquida.
          4. Realizar el conteo de etapas, iniciando por la izquierda (Zona superior de la columna).
               4a. Iniciar por la coordenada de la zona superior de la columna (Xa, Ya).
               4b. Buscar intervalo de equilibrio apropiado sobre el eje X.
               4c. Determinar el respectivo valor sobre el equilibrio (Xb, Yb).
               4d. Trasladarse desde la curva de equilibrio hasta nuevamente la línea operatoria (Xc, Yc).
               4e. Repetir el ciclo, estableciendo que (Xa, Ya) = (Xc, Yc), hasta que Ya sea mayor o igual a Y2i. 

 %}
     
     for i = 1 : (length(XEQ) - 1)
          dXEQ(i) = XEQ(i + 1) - XEQ(i); dYEQ(i) = YEQ(i + 1) - YEQ(i);
          DXEQ(i) = 0.5 * (XEQ(i + 1) + XEQ(i)); DYEQ(i) = dYEQ(i) / dXEQ(i);
     end

switch(Oper)
     case "Absorption"
      % Paso 1 / Step 1: Determinar flujo mínimo de solvente / Determinate minium liquid flow:
          % Paso 1a: Cálculo de diferenciales:
          MRef = max(DYEQ); MFlujMin = MRef; MFlujMinPos = MFlujMin; MFlujMinNeg = MFlujMin; % Pendiente de referencia
          % Paso 1b: Condiciones para ciclo de determinación de pendiente:
          XFlujMin = XEQ; k = 0; Tol = 0.000005;
          CritP = linspace(0, 0, length(XEQ)); CritN = CritP; Crit = 0; % Indicadores / Criterios de que el resultado es apropiado.
     
          while Crit == 0
          % Paso 1c: Planteamiento de rectas con nueva pendiente:
               LinFlujMinPos = @(X) MFlujMinPos * X + (Y2i - MFlujMinPos * X2i);
               LinFlujMinNeg = @(X) MFlujMinNeg * X + (Y2i - MFlujMinNeg * X2i);
               YFlujMinPos = LinFlujMinPos(XFlujMin); YFlujMinNeg = LinFlujMinNeg(XFlujMin);
     
          % Paso 1d: Evaluación de a) Que la línea operatoria sea mayor al equilibrio y b) Que haya un corte que se adopte a la tolerancia esperada:
               for i = 1 : length(XEQ)
                    if YFlujMinPos(i) > YEQ(i) && abs(min(YFlujMinPos - YEQ)) < Tol 
                         CritP(i) = 1; MFlujMin = MFlujMinPos; 
                    else
                         CritP(i) = 0; MFlujMinPos = MFlujMinPos + 0.00001;
                    end
                    if YFlujMinNeg(i) > YEQ(i) && abs(min(YFlujMinNeg - YEQ)) < Tol 
                         CritN(i) = 1; MFlujMin = MFlujMinNeg; 
                    else
                         CritN(i) = 0; MFlujMinNeg = MFlujMinNeg - 0.00001;
                    end
     
          % Paso 1e: Revisión de vector indicador o criterio para finalizar el ciclo.
                    if max(CritP) == 1 && min(CritP) == 1
                         Crit = 1;
                    end
                    if max(CritN) == 1 && min(CritN) == 1
                         Crit = 1;
                    end
               end

          % Paso 1f: Repetición del ciclo y detención del ciclo en caso de muchos intentos
               CritNaux = CritN; CritPaux = CritP; CritP = linspace(0, 0, length(XEQ)); CritN = CritP;
               k = k + 1;
               if k > 100000
                  k = 123456789; Crit = 1;
               end
          end
     
     % Paso 2: Determinación de Flujo de Operación:
     if k ~= 123456789 
          LinFlujMin = @(X) MFlujMin * X + (Y2i - MFlujMin * X2i); YFlujMin = LinFlujMin(XFlujMin); FlujMin = MFlujMin * GS; % Cálculo de Flujo Mínimo
          FlujOp = FlujMin * aFlujMin; MOp = MFlujMin * aFlujMin; BOp = Y2i - MOp * X2i; LinOp = @(X) MOp * X + BOp; % Cálculo de Flujo de Operación
          XOp = XFlujMin; YOp = LinOp(XOp);

     % Paso 3: Caracterización de la Corriente Líquida:
          LSMin = FlujMin; LS = FlujOp; L2 = LS / (1 - X2i); Li2 = L2 * X2i; Li1 = Gi1 + Li2 - Gi2; L1 = LS + Li1; X1i = (Li1 / L1) / (1 - (Li1 / L1));

     % Paso 4: Ejecución del Ciclo de Conteo de Etapas:
          % Paso 4a: Inicio del ciclo:
          Xa = X2i; Ya = Y2i;
          Platos = 0; j = 1;

          while Ya < Y1i
          % Paso 4b: Búsqueda de Intervalo Apropiado:
               for i = 1 : length(YEQ) - 1
                    if YEQ(length(YEQ) - i + 1) > Ya && YEQ(length(YEQ) - i) < Ya
                         Xb1 = XEQ(length(XEQ) - i + 1); Xb2 = XEQ(length(XEQ) - i);
                         Yb1 = YEQ(length(YEQ) - i + 1); Yb2 = YEQ(length(YEQ) - i);
                         Mb = (Yb2 - Yb1) / (Xb2 - Xb1); Bb = Yb2 - Mb * Xb2; Linb = @(Y) (Y - Bb) / Mb;
          % Paso 4c: Transporte de Línea Operatoria a Equilibrio:
                         Yb = Ya; Xb = Linb(Yb);
                    end
               end

          % Paso 4d: Transporte de Equilibrio a Línea Operatoria:
               Xc = Xb; Yc = LinOp(Xc);

          % Paso 4e: Repetición del Ciclo:
               VecXA(j) = Xa; VecXB(j) = Xb; VecXC(j) = Xc; VecYA(j) = Ya; VecYB(j) = Yb; VecYC(j) = Yc;
               Xa = Xc; Ya = Yc;

          % Conteo de Etapas:
               Platos = Platos + 1; j = j + 1;
          end

     % Information Output:
          % Gráfica 1: Equilibrio y Líneas Operatorias:
          subplot(1, 2, 1); grid on; hold on; axis([0 1 0 1]);
          xlabel("Concentración en Fase Líquida (X)"); ylabel("Concentración en Fase de Vapor (Y)");
          title("Equilibrio y Líneas Operatorias para Absorción")
          plot(XEQ, YEQ, "color", [0.6 0.4 0.0], "linewidth", 3); hold on; % Curva de Equilibrio
          plot(XFlujMin, YFlujMin, "color", [0.0 0.8 1.0], "linewidth", 3); hold on; % Línea Operatoria de FLujo Mínimo
          plot(XOp, YOp, "color", [0.0 0.2 1.0], "linewidth", 3); hold on; % Línea Operatoria de Flujo de Operación
          % Gráfica 2: Equilibrio y Desarrollo de Etapas:
          subplot(1, 2, 2); grid on; hold on; axis([0.9 * X2i 1.1 * X1i 0.9 * Y2i 1.1 * Y1i]);
          xlabel("Concentración en Fase Líquida (X)"); ylabel("Concentración en Fase de Vapor (Y)");
          title("Conteo de Etapas de Absorción")
          plot(XEQ, YEQ, "color", [0.6 0.4 0.0], "linewidth", 3); hold on; % Curva de Equilibrio
          plot(XOp, YOp, "color", [0.0 0.2 1.0], "linewidth", 3); hold on; % Línea Operatoria de Flujo de Operación
          % Concentration Lines:
               plot([X1i, X1i], [0 1], "k", "linewidth", 0.5); hold on; plot([X2i, X2i], [0 1], "k", "linewidth", 0.5); hold on;
               plot([0 1], [Y1i, Y1i], "k", "linewidth", 0.5); hold on; plot([0 1], [Y2i, Y2i], "k", "linewidth", 0.5); hold on;
               % Stages Lines:
               for i = 1 : j - 1
                    plot([VecXA(i) VecXB(i)], [VecYA(i) VecYB(i)], "color", [0.8 0.0 0.6], "Linewidth", 2)
                    plot([VecXB(i) VecXC(i)], [VecYB(i) VecYC(i)], "color", [0.8 0.0 0.6], "Linewidth", 2)
               end
          % Salida en Consola:
          TablaFlujos = ["GS" "LS min" "LS" "G1i (In)" "G2i (Out)" "L2i (In)" "L1i (Out)"; GS LSMin LS Gi1 Gi2 Li2 Li1];
          TablaConcent = ["Y2i (Gas Out)" "X2i (Liq. In)" "Y1i (Gas In)" "X1i (Liq. Out)"; Y2i X2i Y1i X1i];
          disp("Desarrollo finalizado."); disp(" ");
          disp("- Operación: Absorción"); disp("- Número de Etapas: " + Platos); disp("- Información de Flujos: "); disp(TablaFlujos); 
          disp("- Información de Concentraciones: "); disp(TablaConcent);

     else % En caso de no haber podido hacer el desarrollo:
          disp("Desafortunadamente no se puede realizar una absorción porque el equilibrio no lo permite para las condiciones dadas :(") 
     end

case("Desorption")
     % Determinate Minium Liquid Flow:
     MRef = abs(min(DYEQ)); MFlujMin = MRef; MFlujMinPos = MFlujMin; MFlujMinNeg = MFlujMin;
     % Paso 1b: Condiciones para ciclo de determinación de pendiente:
     XFlujMin = XEQ; k = 0; Tol = 0.001; 
     CritP = linspace(0, 0, length(XEQ)); CritN = CritP; Crit = 0;   

     while Crit == 0
          LinFlujMinPos = @(X) MFlujMinPos * X + (Y1i - MFlujMinPos * X1i);
          LinFlujMinNeg = @(X) MFlujMinNeg * X + (Y1i - MFlujMinNeg * X1i);
          YFlujMinPos = LinFlujMinPos(XFlujMin); YFlujMinNeg = LinFlujMinNeg(XFlujMin);

          for i = 1 : length(XEQ)
               if YFlujMinPos(i) < YEQ(i) && min(abs(YFlujMinPos - YEQ)) < Tol 
                    CritP(i) = 1; MFlujMin = MFlujMinPos;
               else
                    CritP(i) = 0;
                    MFlujMinPos = MFlujMinPos + 0.00001;
               end
               if YFlujMinNeg(i) < YEQ(i) && min(abs(YFlujMinNeg - YEQ)) < Tol 
                    CritN(i) = 1; MFlujMin = MFlujMinNeg;
               else
                    CritN(i) = 0;
                    MFlujMinNeg = MFlujMinNeg - 0.00001;
               end

               if max(CritP) == 1 && min(CritP) == 1
                    Crit = 1;
               end
               if max(CritN) == 1 && min(CritN) == 1
                    Crit = 1;
               end
          end

          CritNaux = CritN; CritPaux = CritP; CritP = linspace(0, 0, length(XEQ)); CritN = CritP;
          k = k + 1;
          if k > 100000
              k = 123456789; Crit = 1;
          end

     end
     
     % Paso 2: Determinación de Flujo de Operación:
     if k ~= 123456789 
          LinFlujMin = @(X) MFlujMin * X + (Y1i - MFlujMin * X1i); YFlujMin = LinFlujMin(XFlujMin); FlujMin = LS / MFlujMin; % Cálculo de Flujo Mínimo
          FlujOp = FlujMin * aFlujMin; MOp = MFlujMin / aFlujMin; BOp = Y1i - MOp * X1i; LinOp = @(Y) (Y - BOp) / MOp; % Cálculo de Flujo de Operación
          YOp = XFlujMin; XOp = LinOp(YOp); %XOp = XFlujMin; YOp = LinOp(XOp);
          
     % Paso 3: Caracterización de la Corriente Líquida:
          GSMin = FlujMin; GS = FlujOp; G1 = GS / (1 - Y1i); Gi1 = G1 * Y1i; Gi2 = Li2 + Gi1 - Li1; G2 = GS + Gi2; Y2i = (Gi2 / G1) / (1 - (Gi2 / G2));

     % Paso 4: Ejecución del Ciclo de Conteo de Etapas:
          % Paso 4a: Inicio del ciclo:
          Xa = X1i; Ya = Y1i; Platos = 0; j = 1;

          while Xa < X2i
          % Paso 4b: Búsqueda de Intervalo Apropiado sobre el Equilibrio:
               for i = 1 : length(XEQ) - 1
                    if XEQ(length(XEQ) - i + 1) > Xa && XEQ(length(XEQ) - i) < Xa
                         Xb1 = XEQ(length(XEQ) - i + 1); Xb2 = XEQ(length(XEQ) - i);
                         Yb1 = YEQ(length(YEQ) - i + 1); Yb2 = YEQ(length(YEQ) - i);
                         Mb = (Yb2 - Yb1) / (Xb2 - Xb1); Bb = Yb2 - Mb * Xb2; Linb = @(X) Mb * X + Bb; %Linb = @(Y) (Y - Bb) / Mb;
          % Paso 4c: Transporte de Línea Operatoria a Equilibrio:
                         Xb = Xa; Yb = Linb(Xb);
                    end
               end

          % Paso 4d: Transporte de Equilibrio a Línea Operatoria:
               Yc = Yb; Xc = LinOp(Yc); %Xc = Xb; Yc = LinOp(Xc);

          % Paso 4e: Repetición del Ciclo:
               VecXA(j) = Xa; VecXB(j) = Xb; VecXC(j) = Xc; VecYA(j) = Ya; VecYB(j) = Yb; VecYC(j) = Yc;
               Xa = Xc; Ya = Yc;

          % Conteo de Etapas:
               Platos = Platos + 1; j = j + 1;
               if Platos > 100
                    Xa = X2i + 1;
               end
          end
     
     % Information Output:
          % Gráfica 1: Equilibrio y Líneas Operatorias:
          subplot(1, 2, 1); grid on; hold on; axis([0 1 0 1]);
          xlabel("Concentración en Fase Líquida (X)"); ylabel("Concentración en Fase de Vapor (Y)");
          title("Equilibrio y Líneas Operatorias para Desorción")
          plot(XEQ, YEQ, "color", [0.6 0.4 0.0], "linewidth", 3); hold on; % Curva de Equilibrio
          plot(XFlujMin, YFlujMin, "color", [0.0 0.8 1.0], "linewidth", 3); hold on; % Línea Operatoria de FLujo Mínimo
          plot(XOp, YOp, "color", [0.0 0.2 1.0], "linewidth", 3); hold on; % Línea Operatoria de Flujo de Operación
          % Gráfica 2: Equilibrio y Desarrollo de Etapas:
          subplot(1, 2, 2); grid on; hold on; axis([0.9 * X1i 1.1 * X2i 0.9 * Y1i 1.1 * Y2i]);
          xlabel("Concentración en Fase Líquida (X)"); ylabel("Concentración en Fase de Vapor (Y)");
          title("Conteo de Etapas de Desorción")
          plot(XEQ, YEQ, "color", [0.6 0.4 0.0], "linewidth", 3); hold on; % Curva de Equilibrio
          plot(XOp, YOp, "color", [0.0 0.2 1.0], "linewidth", 3); hold on; % Línea Operatoria de Flujo de Operación
               % Concentration Lines:
               plot([X1i, X1i], [0 1], "k", "linewidth", 0.5); hold on; plot([X2i, X2i], [0 1], "k", "linewidth", 0.5); hold on;
               plot([0 1], [Y1i, Y1i], "k", "linewidth", 0.5); hold on; plot([0 1], [Y2i, Y2i], "k", "linewidth", 0.5); hold on;
               % Stages Lines:
               for i = 1 : j - 1
                    plot([VecXA(i) VecXB(i)], [VecYA(i) VecYB(i)], "color", [0.8 0.0 0.6], "Linewidth", 2)
                    plot([VecXB(i) VecXC(i)], [VecYB(i) VecYC(i)], "color", [0.8 0.0 0.6], "Linewidth", 2)
               end
          % Salida en Consola:
          TablaFlujos = ["GS" "GS min" "LS" "G1i (In)" "G2i (Out)" "L2i (In)" "L1i (Out)"; GS GSMin LS Gi1 Gi2 Li2 Li1];
          TablaConcent = ["Y2i (Gas Out)" "X2i (Liq. In)" "Y1i (Gas In)" "X1i (Liq. Out)"; Y2i X2i Y1i X1i];
          disp("Desarrollo finalizado."); disp(" ");
          disp("- Operación: Desorción"); disp("- Número de Etapas: " + Platos); disp("- Información de Flujos: "); disp(TablaFlujos)
          disp("- Información de Concentraciones: "); disp(TablaConcent);

     else % En caso de no haber podido hacer el desarrollo:
          disp("Desafortunadamente no se puede realizar una desorción porque el equilibrio no lo permite para las condiciones dadas :(") 
     end

end
