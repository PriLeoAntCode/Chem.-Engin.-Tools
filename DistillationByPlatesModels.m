% Operaciones de Separación: Modelos de Destilación por Etapas
% Última Edición: 21 de enero de 2024

%{ 
DESCRIPCIÓN --------------------------------------------------------------------------------------------------------------------------------------- 
     El siguiente código permite el modelado de procedimiento de destilación de mezcla binaria empleando las metodologías de McCabe-Thiele y 
     Ponchon-Savarit. 

     El desarrollo planteado consiste en el manejo de los equilibrios como unión de segmentos rectos con los cuales se buscará la intersección de los
     desarrollos de etapas de forma simple debido a la facilidad que es resolver ecuaciones de rectas.

     Se entrega al final un desarrollo sobre gráficas que permite observar el procedimiento modelado y su viabilidad. Se requiere que 
     por parte del usuario se suministre en el código los datos del equilibrio a desarrollar, las condiciones de entrada y salida de la columna y el
     método que desea aplicar.
%}

% INGRESO DE DATOS --------------------------------------------------------------------------------------------------------------------------------------- 
     
     clear

     % Datos de Equilibrio X vs Y
          EquiX = [0.0000 0.00584 0.0120 0.0260 0.0500 0.0738 0.1020 0.1176 0.1400 0.1500 0.1750 0.2000 0.3000 0.4000 0.4730 0.5260 0.5400 0.5650 ... 
                   0.5850 0.6000 0.6620 0.67500 0.7000 0.7140 0.8000 0.8500 0.8808 0.8900 0.9000 0.9200 0.9500 0.9657 0.9871 1.0000];
          EquiY = [0.0000 0.045705 0.1140 0.1570 0.2930 0.3665 0.4300 0.4855 0.5140 0.5220 0.5600 0.5900 0.6750 0.7350 0.7650 0.7940 0.8010 0.8050 ...
                   0.8160 0.8310 0.8570 0.865000 0.8740 0.8780 0.9180 0.9300 0.9417 0.9560 0.9610 0.9650 0.9810 0.9569 0.9778 1.0000];
          nXY = length(EquiX);

     % Datos de Equilirio H vs XY
          EntRocX = [0 0.094594595 0.198198198 0.297297297 0.398648649 0.502252252 0.601351351 0.70045045 0.806306306 0.903153153 1];
          EntRocY = [46947.44948 45465.91367 44309.28894 43153.39763 42485.60637 41817.44838 41312.84609 40808.24379 39814.07459 38984.19451 37828.66992];
          EntBurX = [0 0.094594595 0.195945946 0.295045045 0.396396396 0.502252252 0.601351351 0.70045045 0.804054054 0.903153153 1];
          EntBurY = [7381.642158 5248.817338 4418.203821 3750.779273 3571.454765 3879.863581 3863.728043 3847.592504 3830.723532 4140.232498 4124.463677];
          nRoc = length(EntRocX); nBur = length(EntBurX);

     % Condiciones de Trabajo Generales:
     xD = 0.914427648; y1 = xD; 
     zF = 0.359968038;
     xW = 0.005648938;
     F = 216.7622048; D = 84.51272428; W = 132.24919;

     % Condiciones de Trabajo para Método McCabe - Thiele:
     q = 1.035696198;
     LI = 73.47529571; VI = 157.98802;
     DeltaLJ = 224.4997914; DeltaVJ = 7.737586546;
     LK = LI + DeltaLJ; VK = VI + DeltaVJ;

     % Condiciones de Trabajo para Método Ponchon - Savarit:
     DeltaD = 200000;
     DeltaW = -10000;
     Condensador = "Total";
     Rehervidor = "Total";

     % Método a Desarrollar:
     Metodo = "McCabeThiele";
     %Metodo = "PonchonSavarit";

switch(Metodo)

% MÉTODO: MCCABE - THIELE PARA ALIMENTACIÓN ÚNICA ****************************************************************************************************************
case "McCabeThiele"
     % 1. CONSIDERACIONES INICIALES:
          % Planteamiento de Líneas Operatorias: 1. Lín. Oper. de Enriquecimiento, 2. Lín. Oper.de Alimentación, 3. Lín. Oper. de Agotamiento.
               % Pendientes y Cortes de cada línea:
               m1 = (LI / VI); m2 = q / (q - 1); m3 = (LK / VK);
               b1 = (D / VI) * xD; b2 = -zF / (q - 1); b3 = -(W / VK) * xW;
               % Expresiones para las líneas operatorias de la forma Y = f(X) y X = g(y) = f(y)^-1
               LiOpEnrY = @(x) m1 * x + b1; LiOpEnrX = @(y) (y - b1) / m1;
               LiOpAliY = @(x) m2 * x + b2; LiOpAliX = @(y) (y - b2) / m2;
               LiOpAgoY = @(x) m3 * x + b3; LiOpAgoX = @(y) (y - b3) / m3;
          % Determinación de Cortes entre Líneas Operatorias:
               % Fórmula General: Y = m1 * x + b1; Y = m2 * x + b2; -> Y = Y -> x = (b2 - b1) / (m1 - m2)
               % Igualdad entre Línea Operatoria de Enriquecimiento y de Alimentación:
               xEnriAlim = (b2 - b1) / (m1 - m2);
               % Igualdad entre Línea Operatoria de Alimentación y de Agotamiento:
               xAlimAgot = (b3 - b2) / (m2 - m3);
     
     % 2. ESTABLECIMIENTO DE CICLO DE CONTEO DE ETAPAS:
          %{
          Descripción del procedimiento: Cada etapa consta de un triángulo rectángulo apuntando hacia abajo. El punto sobre la línea 
               operatoria será (xa, ya), el punto del ángulo recto sobre la curva de equilibrio será (xb, ya) y el punto restante para una nueva
               etapa será (xb, yb), que será luego el punto (xa, ya) de la siguiente etapa. Así, se plantea el siguiente proceso del Ciclo:
               1. Buscar un intervalo de puntos de equilibrio en el que el valor 'ya' se encuentre entre los valores de 'y' en equilibrio.
               2. Establecer la ecuación de recta entre los dos puntos de equilibrio tomados en el Paso 1.
               3. Realizar el desplazamiento desde el punto (xa, ya) hasta el punto (xb, ya) resolviendo la ecuación de la forma X = f(Y) planteada 
                    en el Paso 2.
               4. Emplear la ecuación de la línea operatoria apropiada (De enriquecimiento o de agotamiento según un análisis de si el valor de 'xa' es
                    mayor o menor al del valor de x de alimentación o no, respectivamente).
               5. Realizar el desplazamiento desde el punto (xb, ya) hasta el punto (xb, yb) resolviendo la ecuación de la forma X = f(Y) tomada en el
                    Paso 4.
               5. Continuar con el proceso, estableciendo el punto (xb, yb) como (xa, ya), hasta que la concentración de xa sea menor o igual a la de xW.
          %}

          % Condiciones Iniciales:
               xa = xD; ya = y1; xb = 1; yb = 1;
          % Establecimiento de conjuntos de puntos obtenidos:
               PuntosX(1) = xD; PuntosY(1) = y1; i = 0; L = 1;

          % Ejecución del Ciclo de Iteración: 
               while xa > xW
                    % PASO 1: ---------------------------------------------------------------------------------------------------------------------------------
                    if ya > EquiY(nXY - i) % Verificación de que 'ya' se encuentre debajo de un punto de equilibrio. La respuesta "Apropiada" es No.
                         i = i + 1;  % La solución es revisar una siguiente posición (Nótese que el conteo es desde el final hacia el comienzo)

                    elseif ya < EquiY(nXY - i) && ya > EquiY(nXY - i - 1) % Verificación de que "ya" se encuentre entre dos puntos de equilibrio sucesivos. 
                         % La respuesta "Apropiada" es Sí:

                    % PASO 2: ---------------------------------------------------------------------------------------------------------------------------------
                         % Ecuación de Recta en Intervalo de Equilibrio Tomado:
                              m = (EquiY(nXY - i) - EquiY(nXY - i - 1)) / (EquiX(nXY - i) - EquiX(nXY - i - 1));
                              b = (EquiY(nXY - i) - m * EquiX(nXY - i));
                              % y - y1 = m * (x - x1) -> y = m * x + (y1 - m * x1)
                              LiEqY = @(x) m * x + b;
                              LiEqX = @(y) (y - b) / m;
                    
                    % PASO 3: ---------------------------------------------------------------------------------------------------------------------------------
                         % Transporte desde Línea Operatoria a Curva de Equilibrio:
                              xb = LiEqX(ya);
                    
                    % PASO 4 y 5: ---------------------------------------------------------------------------------------------------------------------------------
                         % Transporte desde Curva de Equilibrio a Curva de Equilibrio:
                              if xb > xEnriAlim
                                   yb = LiOpEnrY(xb);
                              elseif xb <= xEnriAlim
                                   yb = LiOpAgoY(xb);
                              end

                   % PASO 6: ---------------------------------------------------------------------------------------------------------------------------------
                         % Conteo de Coordenadas en Obtenidas:
                              L = L + 1;
                              PuntosX(L) = xb;
                              PuntosY(L) = yb;
                         % Establecimiento de nuevo punto "a" para iniciar:
                              xa = xb;
                              ya = yb;           
                      
                    else % Corrección en caso de que no se cumplan ninguna de las dos condiciones anteriores:
                         i = i + 1;
                    end 
               end
         
     % 3. ENTREGA DE INFORMACIÓN
          % Primera Gráfica: Ubicación de Equilibrio y Líneas Operatorias como Funciones
               % Detalles Globales:
               subplot(1, 2, 1); hold on; axis([0 1 0 1]); hold on;
               xlabel("Fracción molar de Metanol en Líquido (x)"); ylabel("Fracción molar de Metanol en Vapor (y)"); hold on;
               title("Curva de Equilibrio y Líneas Operatorias"); grid on; hold on;
               % Gráfica de Equilibrio:        
               plot(EquiX, EquiY, "Color", [0.2 0.6 0.0], "linewidth", 3); hold on; % Curva de Equilibrio
               plot(EquiX, EquiX, "--", "Color", [0.2 0.6 0.4], "linewidth", 2.5); hold on; % Línea de 45°
               % Gráfica de Líneas Operatorias:
               plot(linspace(0, 1, 2), LiOpAgoY(linspace(0, 1, 2)), "Color", [1.0 0.4 0.0], "linewidth", 2); hold on; % Línea de Agotamiento
               plot(linspace(0, 1, 2), LiOpAliY(linspace(0, 1, 2)), "Color", [1.0 0.6 0.6], "linewidth", 2); hold on; % Línea de Alimentación
               plot(linspace(0, 1, 2), LiOpEnrY(linspace(0, 1, 2)), "Color", [1.0 0.6 0.2], "linewidth", 2); hold on; % Línea de Enriquecimiento
     
          % Segunda Gráfica: Ubicación de Líneas Operatorias con Dominios Correctos y Representación de Etapas
               % Detalles Globales:
               subplot(1, 2, 2); hold on; axis([0 1 0 1]); hold on;
               xlabel("Fracción molar de Metanol en Líquido (x)"); ylabel("Fracción molar de Metanol en Vapor (y)"); 
               title("Conteo de Etapas de Proceso"); grid on; hold on;
               % Gráfica de Equilibrio:  
               plot(EquiX, EquiY, "Color", [0.2 0.6 0.0], "linewidth", 3); hold on; % Curva de Equilibrio
               plot(EquiX, EquiX, "--", "Color", [0.2 0.6 0.4], "linewidth", 3); hold on; % Curva de Equilibrio
               %plot(EquiX, EquiY, ".", "Color", [0.2 0.6 0.0], "linewidth", 3); hold on;
               % Gráfica de Líneas Operatorias y Rectas de Concentraciones de Entradas y Salidas:
               plot(linspace(0, xAlimAgot, 2), LiOpAgoY(linspace(0, xAlimAgot, 2)), "Color", [1.0 0.4 0.0], "linewidth", 2); hold on; % Línea de Agotamiento
               plot(linspace(xEnriAlim, 1, 2), LiOpEnrY(linspace(xEnriAlim, 1, 2)), "Color", [1.0 0.6 0.2], "linewidth", 2); hold on; % Línea de Enriquecimiento
               plot([xD, xD], [0, 1], "k", "linewidth", 1.0); plot([zF, zF], [0, 1], "k", "linewidth", 1.0); plot([xW, xW], [0, 1], "k", "linewidth", 1.0)
               % Gráfica de etapas:
               Etapas = 0;
               m = length(PuntosX);
     
               for j = 1 : m - 1
                   % Dibujo de Recta Horizontal / Tendencia al Equilibrio:
                   RecHorizonX = [PuntosX(j), PuntosX(j + 1)]; RecHorizonY = [PuntosY(j) PuntosY(j)];
                   plot(RecHorizonX, RecHorizonY, "Color", [0.0, 0.2, 1.0], "linewidth", 1.5); hold on;
                   % Dibujo de Recta Vertical / Cumplimiento de Balance de Materia:
                   RecVertiX = [PuntosX(j + 1) PuntosX(j + 1)]; RecVertiY = [PuntosY(j) PuntosY(j + 1)];
                   plot(RecVertiX, RecVertiY, "Color", [0.2 0.4 1.0], "linewidth", 1.5); hold on;
                   % Conteo de Etapas:
                   Etapas = Etapas + 1;
               end
     
          % Tabla con Etapas y Respuestas en Consola:
               TablaEtapas(1, 1) = "Etapa"; TablaEtapas(1, 2) = "Conc. X In"; TablaEtapas(1, 3) = "Conc. X Out"; 
               TablaEtapas(1, 4) = "Conc. Y In"; TablaEtapas(1, 5) = "Conc. Y Out";
     
               for i = 2 : length(PuntosX)
                    TablaEtapas(i, 1) = strcat("Etapa ", num2str(i - 1));
                    TablaEtapas(i, 2) = PuntosX(i - 1); TablaEtapas(i, 3) = PuntosX(i); TablaEtapas(i, 4) = PuntosY(i); TablaEtapas(i, 5) = PuntosY(i - 1);
               end

               disp("El procedimiento ha finalizado. Los resultados se presentan a continuación: "); disp(" ");
               disp("- Número de Etapas: " + Etapas); disp("- Tabla de Etapas: "); disp(TablaEtapas)
          
% MÉTODO: PONCHON-SAVARIT PARA ALIMENTACIÓN ÚNICA ****************************************************************************************************************
case "PonchonSavarit"
     % 1. CONSIDERACIONES INICIALES:
          % Recta Destilado - Alimentación - Residuo (DAW): 
               % Puntos: (xD, DeltaD), (xW, DeltaW), y - y1 = m * (x - x1) -> y = m * x + (y1 - m * x1), Y = m1 * x + b1; 
               mDAW = (DeltaD - DeltaW) / (xD - xW); bDAW = (DeltaD - mDAW * xD);
               RectaDAWX = @(x) mDAW * x + (DeltaD - mDAW * xD); RectaDAWY = @(y) (y - (DeltaD - mDAW * xD)) / mDAW;

          % Cortes de la recta DAW con las curvas de Rocío (Superior) y Burbuja (Inferior
               xRocDAW = 0; xBurDAW = 0;
               % Y = m2 * x + b2; -> x = (b2 - b1) / (m1 - m2)
               % Corte en curva de rocío (Superior):
               for i = 1 : nRoc - 1 
                    m1 = (EntRocY(i + 1) - EntRocY(i)) / (EntRocX(i + 1) - EntRocX(i)); b1 = (EntRocY(i) - m1 * EntRocX(i));
                    xRocDAW = (bDAW - b1) / (m1 - mDAW);
                    
                    if xRocDAW >= EntRocX(i) && xRocDAW <= EntRocX(i + 1)
                         xRocDAWTrue = xRocDAW;
                    end
               end
               % Corte en curva de burbuja (Inferior)
               for i = 1 : nBur - 1 
                    m1 = (EntBurY(i + 1) - EntBurY(i)) / (EntBurX(i + 1) - EntBurX(i)); b1 = (EntBurY(i) - m1 * EntBurX(i));
                    xBurDAW = (bDAW - b1) / (m1 - mDAW);
                    
                    if xBurDAW >= EntBurX(i) && xBurDAW <= EntBurX(i + 1)
                         xBurDAWTrue = xBurDAW;
                    end
               end

     % 2. ESTABLECIMIENTO DE CICLOS DE CONTEO DE ETAPAS:
          %{
          Descripción del procedimiento: El procedimiento consta de dos etapas: Realizar un desarrollo respecto a una recta global de balance de materia
               a. A su izquierda (Agotamiento) y b. A su derecha (Enriquecimiento).

               El procedimiento para el desarrollo en la zona de enriquecimiento (D) es el siguiente
               D1. Definir si el condensador es Total o Parcial. Si es total, se tiene que xD = x0 = yD = y1, por lo que puede suministrarse xD o yD. Si 
                    es parcial, se tiene que x0 > xD = Eq(yD) = y1, por lo que hay que verificar cuál valor es el que se suministra. En todo caso, se inicia
                    sobre un punto (xa, ya) que se encuentra ubicado sobre la recta de 45°.
               D2. Buscar un intervalo de puntos de equilibrio en el que el valor 'yD' se encuentre entre los valores de 'y' en equilibrio.
               D3. Establecer la ecuación de recta entre los dos puntos de equilibrio tomados en el Paso D2.
               D4. Realizar el desplazamiento horizontal desde el punto (xa, ya) en la curva de equilibrio hasta el punto (xb, ya) en la recta de 45°, 
                    resolviendo la ecuación de la forma X = f(Y) planteada en el Paso D3.
               D5. Tomar la coordenada 'xb' y buscar un intervalo de puntos de burbuja en el que el valor 'xb' se encuentre entre los valores de 
                    'zb' en el equilibrio.
               D6. Establecer la ecuación de recta entre los dos puntos de curva de burbuja tomados en el Paso D5.
               D7. Realizar el desplazamiento vertical desde el punto (xb, ya) en la curva de equilibrio hasta el punto (xb, Hxb) en la curva de burbuja,
                    resolviendo la ecuación de la forma X = f(Y) planteada en el Paso W6.
               D8. Establecer la ecuación de recta entre el punto (xD, DeltaD) y el punto (xb, Hxb), el cual fue tomado en el Paso D7. 
               D9. Determinar el corte de la recta del Paso D8 con la curva de rocío, hallando la solución de la ecuación con la recta de cada segmento
                    de la curva y verificando si es apropiada o no la solución. El punto resultante corresponderá a (xc, Hyc).
               D10. Realizar el desplazamiento vertical desde el punto (xc, Hyc) en la curva de rocío hasta la recta de 45°, estableciendo el punto 
                    (xc, yc = xc).
               D11. Repetir el procedimiento desde el Paso D4 estableciendo el punto (xa, ya) = (xc, yc) y continuando mientras no ocurra alguna de las
                    siguientes situaciones:
                    - Convergencia: Se debe establecer un valor máximo de iteraciones frente al posible peligro de convergencia.
                    - Cruce a Agotamiento: Se debe estar verificando que las coordenadas tomadas en la curva de equilibrio se mantengan siempre a la
                      derecha de la recta DAW.
               
               El procedimiento para el desarrollo en la zona de agotamiento (W) es el siguiente:
               W1. Definir si el rehervidor es Total o Parcial. Si es total, se tiene que yW = yN+1 = xW = xN, por lo que puede suministrarse xW o yW. Si
                    es parcial, se tiene que yW > yN+1 = Eq(xW) = xN, por lo que hay que verificar cuál valor es el que se suministra. En todo caso, se inicia
                    sobre un punto (xa, ya) que se encuentra ubicado sobre la recta de 45°.
               W2. Buscar un intervalo de puntos de equilibrio en el que valor 'xW' se encuentre entre los valores de 'x' en equilibrio.
               W3. Establecer la ecuación de recta entre los dos puntos de equilibrio tomados en el Paso W2.
               W4. Realizar el desplazamiento vertical desde el punto (xa, ya) en la recta de 45° hasta el punto (xa, yb) en la curva de equilibrio,
                    resolviendo la ecuación de la forma Y = f(X) planteada en el paso W3.
               W5. Tomar la coordenada 'yb' y realizar el desplazamiento horizontal desde el punto (xa, yb) en la curva de equilibrio hasta el punto
                    (xb = yb, yb) en la curva de 45°.
               W6. Tomar la coordenada 'xb' y buscar un intervalo de puntos de rocío en el que el valor 'xb' se encuentre entre los valores de 'zb' en el
                    equilibrio.
               W7. Establecer la ecuación de recta entre los dos puntos de curva de rocío tomados en el Paso W6.
               W8. Realizar el desplazamiento vertical desde el punto (xb, yb) en la recta de 45° hasta el punto (xb, Hyb) en la curva de rocío, 
                    resolviendo la ecuación de la forma Y = f(X) planteada en el Paso W7.
               W9. Establecer la ecuación de recta entre el punto (xW, DeltaW) y el punto (xb, Hyb), el cual fue tomado en el paso W8.
               W10. Determinar el corte de la recta del paso W9 con la curva de burbuja, hallando la solución de la ecuación con la recta de cada
                    segmento de la curva y verificando si es apropiada o no la solución. El punto resultante corresponderá a (xc, Hxc).
               W11. Realizar el desplazamiento vertical desde el punto (xc, Hxc) en la curva de burbuja hasta la recta de 45°, estableciendo el punto 
                    (xd = xc, yd).
               W12. Repetir el procedimiento desde el Paso W5 estableciendo el punto (xa, yb) = (xd, yd) y continuando mientras no ocurra alguna de las
                    siguientes situaciones:
                    - Convergencia: Se debe establecer un valor máximo de iteraciones frente al posible peligro de convergencia.
                    - Cruce a Enriquecimiento: Se debe estar verificando que las coordenadas tomadas en la curva de equilibrio se mantengan siempre a la
                      izquierda de la recta DAW.

          Nomenclatura de vectores:
               Para la zona de enriquecimiento (D):
               - xXYD, yXYD: Valores (x, y) en la recta de 45°
               - xEqD, yEqD: Valores (x, y) en la curva de equilibrio.
               - xBurD, yBurD: Valores (x, H) en la curva de burbuja
               - xRocDTrueD, yRocD: Valores (y, H) en la curva de rocío. El primero recibe "True" por ser el corte que debe realizar
          %}

          % PASO D1: ¿Condensador Total o Parcial? ---------------------------------------------------------------------------------------------------------------------------------
               switch(Condensador)
                    case "Total" % Caso más sencillo, donde ambos puntos están sobre la línea de equilibrio.
                         xXYD(1) = xD; yXYD(1) = xD; xa = xD; ya = xD; k = 1; 
                         xa = xD; ya = xa; k = 1; i = 0;
                    case "Parcial" % Se ingresa la composición de Destilado Líquido y se halla la composición en vapor.
                         xXYD(1) = xD; yXYD(1) = xD; xa = xD; ya = xD; k = 1; 
                         xa = xD; ya = xa; k = 1; i = 0;
               end
               
          % Ejecución del Ciclo de Iteración por Derecha: 
               xBurD = linspace(1, 1, 2);
               while k < 50 && min(xBurD) > xBurDAW 
                    % PASO D2: Búsqueda de Intervalo en Curva de Equilibrio XY ---------------------------------------------------------------------------------------------------------------------------------
                    if ya > EquiY(nXY - i) % Verificación de que 'ya' se encuentre fuera de un intervalo de equilibrio. La respuesta "Apropiada" es No.
                         i = i + 1;  % La solución es revisar una siguiente posición:
     
                    elseif ya < EquiY(nXY - i) && ya > EquiY(nXY - i - 1) % Verificación de que "ya" se encuentre en un intervalo de equilibrio. 
                         % La respuesta "Apropiada" es Sí:                   
                  
                    % PASO D3: Ecuación de Recta en Curva de Equilibrio ---------------------------------------------------------------------------------------------------------------------------------
                         % Ecuaciones de Recta en Intervalo de Equilibrio Tomado:
                         mEq = (EquiY(nXY - i) - EquiY(nXY - i - 1)) / (EquiX(nXY - i) - EquiX(nXY - i - 1)); bEq = (EquiY(nXY - i) - mEq * EquiX(nXY - i));
                         % y - y1 = m * (x - x1) -> y = m * x + (y1 - m * x1)
                         LiEqY = @(x) mEq * x + bEq; LiEqX = @(y) (y - bEq) / mEq;

                    % PASO D4: Transporte desde Línea de 45° a Curva de Equilibrio ---------------------------------------------------------------------------------------------------------------------------------
                         xEqD(k) = LiEqX(ya); xBurD(k) = xEqD(k); yEqD(k) = yXYD(k);
                     
                    % PASO D5: Búsqueda de Intervalo en Curva de Burbuja ---------------------------------------------------------------------------------------------------------------------------------
                         for j = 1 : nBur - 1 
                              if xBurD(k) >= EntBurX(j) && xBurD(k) <= EntBurX(j + 1) % Verificar el intervalo de puntos de Curva de Burbuja
                    % PASO D6: Ecuación de Recta en Curva de Burbuja ---------------------------------------------------------------------------------------------------------------------------------
                                   ma = (EntBurY(j + 1) - EntBurY(j)) / (EntBurX(j + 1) - EntBurX(j)); ba = (EntBurY(j) - ma * EntBurX(j)); 
                                   % y - y1 = m * (x - x1) -> y = m * x + (y1 - m * x1)
                                   LiBurY = @(x) ma * x + ba; LiBurX = @(y) (y - ba) / ma; % Ecuaciones de recta en el intervalo de burbuja tomado
                    % PASO D7: Transporte desde Curva de Equilibrio hasta Curva de Burbuja ---------------------------------------------------------------------------------------------------------------------------------
                                   yBurD(k) = LiBurY(xBurD(k)); % Toma del valor sobre la Curva de Burbuja
                              end    
                         end
                    % PASO D8: Ecuación de Recta desde Curva de rocío hasta DeltaD --------------------------------------------------------------------------------------------------------------------------------
                         mbD = (yBurD(k) - DeltaD) / (xBurD(k) - xD); bbD = (yBurD(k) - mbD * xBurD(k)); % Recta entre Curva de Burbuja y Delta D
               
                    % PASO D9: Determinación de Corte de Recta sobre Curva de Rocío y Transporte ----------------------------------------------------------
                         xRoc = 0;
                         for j = 1 : nRoc - 1
                              mb = (EntRocY(j + 1) - EntRocY(j)) / (EntRocX(j + 1) - EntRocX(j)); bb = (EntRocY(j) - mb * EntRocX(j)); 
                              LiRocY = @(x) mb * x + bb; LiRocX = @(x) (y - bb) / mb; % Ecuaciones de recta en la curva de rocío
                              xRoc = (bbD - bb) / (mb - mbD); % Corte en la Curva de Rocío
                         
                              % Verificar si el corte en la curva de rocío es apropiado para el intervalo tomado:
                              if xRoc >= EntRocX(j) && xRoc <= EntRocX(j + 1) 
                                   xRocTrueD(k) = xRoc;
                                   yRocD(k) = LiRocY(xRocTrueD(k));
                              end
                         end
               
                    % PASO D10: Transporte desde Curva de Rocío hasta Línea Y = X -----------------------------------------------------------------------------
                         xXYD(k + 1) = xRocTrueD(k); yXYD(k + 1) = xXYD(k + 1); xa = xXYD(k + 1); ya = xXYD(k + 1);
                         k = k + 1;

                    else % Corrección en caso de que no se cumplan ninguna de las dos condiciones anteriores:
                         i = i + 1;
                    end 
               end  

          % PASO W1: ¿Rehervidor Total o Parcial? ---------------------------------------------------------------------------------------------------------------------------------
               switch(Rehervidor)
                    case("Total")
                         xa = xW; ya = xa; k = 2; i = 1;
                         xXYW(1) = xa;
                         yXYW(1) = ya;
                    case("Parcial")
                         xa = xW; k = 2; i = 1;
                         xXYW(1) = xa;
               end

          % Ejecución del Ciclo de Iteración por Derecha: 
               xRocW = linspace(0, 0, 2);
               while k < 50 && max(xRocW) < xRocDAWTrue
                    % PASO D2: Búsqueda de Intervalo en Curva de Equilibrio XY ---------------------------------------------------------------------------------------------------------------------------------
                    if xa < EquiX(i) % Verificación de que 'xa' se encuentre debajo de un punto de equilibrio. La respuesta "Apropiada" es No.
                         i = i + 1;  % La solución es revisar una siguiente posición:
                    elseif xa > EquiX(i) && xa < EquiX(i + 1) % Verificación de que "xa" se encuentre entre dos puntos de equilibrio sucesivos. 
                         % La respuesta "Apropiada" es Sí.                  
     % PASO 2: Llevar al equilibrio verticalmente:
                    % PASO D3: Ecuación de Recta en Curva de Equilibrio ---------------------------------------------------------------------------------------------------------------------------------
          % Ecuación de Recta en Intervalo de Equilibrio Tomado:
               mEq = (EquiY(i + 1) - EquiY(i)) / (EquiX(i + 1) - EquiX(i)); bEq = (EquiY(i) - mEq * EquiX(i));
               LiEqY = @(x) mEq * x + bEq; LiEqX = @(y) (y - bEq) / mEq; % Ecuaciones de recta en el intervalo tomado:
               % y - y1 = m * (x - x1) -> y = m * x + (y1 - m * x1)

               if k == 2
                    xEqW(k - 1) = xXYW(k - 1); yEqW(k - 1) = LiEqY(xEqW(k - 1));
               elseif k > 2
                    yEqW(k - 1) = LiEqY(xEqW(k - 1));
               end

     % PASO 3: Llevar a la Igualdad horizontalmente:
               yXYW(k) = yEqW(k - 1);
               xXYW(k) = yXYW(k);

     % PASO 4: Llevar a la Curva de Rocío Verticalmente:
          % Subir hasta la curva de rocío:    
               for j = 1 : nRoc - 1 
                    if xXYW(k) >= EntRocX(j) && xXYW(k) <= EntRocX(j + 1) % Verificar 
                         ma = (EntRocY(j + 1) - EntRocY(j)) / (EntRocX(j + 1) - EntRocX(j)); ba = (EntRocY(j) - ma * EntRocX(j));
                         LiRocY = @(x) ma * x + ba; LiRocX = @(y) (y - ba) / ma;
                         xRocW(k - 1) = xXYW(k); yRocW(k - 1) = LiRocY(xRocW(k - 1));
                    end
               end

     % PASO 5: REALIZAR BALANCE DE MATERIA CON W Y TOMAR CORTE EN CURVA DE BURBUJA:
               xBur = 0;
               for j = 1 : nBur - 1 % Corte en curva de rocío (Superior)
                    mb = (EntBurY(j + 1) - EntBurY(j)) / (EntBurX(j + 1) - EntBurX(j)); bb = (EntBurY(j) - mb * EntBurX(j)); % Recta en Burbuja
                    LiBurY = @(x) mb * x + bb; LiBurX = @(x) (y - bb) / mb;
                    mbW = (yRocW(k - 1) - DeltaW) / (xRocW(k - 1) - xW); bbW = (yRocW(k - 1) - mbW * xRocW(k - 1)); % Recta entre Curva de Rocío y Delta W
                    xBur = (bbW - bb) / (mb - mbW);
                    
                    if xBur >= EntBurX(j) && xBur <= EntBurX(j + 1)
                         xBurTrueW(k - 1) = xBur;
                         yBurW(k - 1) = LiBurY(xBurTrueW(k - 1));
                    end
               end
               
     % PASO 6: ESTABLECER SIGUIENTE PUNTO HASTA EL EQUILIBRIO;
               xEqW(k) = xBurTrueW(k - 1);
               xa = xEqW(k);

               if xRocW(k - 1) > xRocDAWTrue 
                    k = 5000;
               else
                    k = k + 1;
               end

          else % Corrección en caso de que no se cumplan ninguna de las dos condiciones anteriores:
               i = i + 1;
          end 
     end 


     % 3. ENTREGA DE INFORMACIÓN
          % Configuración General:
               % Primera Gráfica: Desarrollo en Gráfica H vs XY
                    % Detalles Globales
                    subplot(2, 2, 1); hold on; axis([0 1 0.8 * min(EntBurY) 1.2 * max(EntRocY)]); hold on;
                    xlabel("Fracción Molar de Especie Volátil (x, y)"); ylabel("Entalpía de la Mezcla (H)"); 
                    title("Desarrollo Ponchon-Savarit en Gráfica de Energía"); grid on; hold on;
                    % Gráfica de Equilibrio
                    plot(EntBurX, EntBurY); hold on; plot(EntRocX, EntRocY); hold on;
                    % Línea DAW:
                    plot(linspace(0, 1, 10), RectaDAWX(linspace(0, 1, 10)));
                    %plot([xRocDAWTrue xRocDAWTrue], [-100000, 100000]); hold on;
                    %plot([xBurDAWTrue xBurDAWTrue], [-100000, 100000]); hold on;
               % Segunda Gráfica: Desarrollo en Gráfica X vs Y
                    % Detalles Globales
                    subplot(2, 2, 3); hold on; axis([0 1 0 1]); hold on;
                    xlabel("Fracción Molar de Especie Volátil en Líquido (x)"); ylabel("Fracción Molar de Especie Volátil en Vapor (y)"); 
                    title("Desarrollo Ponchon-Savarit en Gráfica de Equilibrio"); grid on; hold on;
                    % Gráfica de Equilibrio
                    plot(EquiX, EquiY); hold on; plot(EquiY, EquiY); hold on;
               % Tercera Gráfica: Conteo de Etapas en Gráfica X vs y
                    subplot(2, 2, 4); hold on; axis([0 1 0 1]); hold on;
                    xlabel("Fracción Molar de Especie Volátil en Líquido (x)"); ylabel("Fracción Molar de Especie Volátil en Vapor (y)"); 
                    title("Conteo de Etapas de Proceso"); grid on; hold on;
                    % Gráfica de Equilibrio
                    plot(EquiX, EquiY); hold on; plot(EquiY, EquiY); hold on;
          % Desarrollo en cada gráfica:
               Min = -999999; Max = abs(Min);
               for p = 1 : length(xBurD) - 1
                    % Segunda Gráfica
                    subplot(2, 2, 3)
                    plot([xXYD(p) xEqD(p)], [yXYD(p), yEqD(p)], "Color", 'c'); hold on; % Línea entre Y = X y Curva de Equilibrio
                    plot([xEqD(p) xEqD(p)], [yEqD(p) Max], "Color", [1.0 0.0 0.6]); hold on; % Linea entre Curva de Equilibrio y Lado Superior
                    % Primera Gráfica
                    subplot(2, 2, 1)
                    plot([xBurD(p), xBurD(p)], [Min, yBurD(p)], "Color", [1.0 0.0 0.6]); hold on; % Línea entre Lado Inferior y Curva de Burbuja
                    plot([xBurD(p) xRocTrueD(p)], [yBurD(p) yRocD(p)], "Color", [0.2 0.6 0.0]); hold on; % Línea entre Curva de Burbuja y Curva de Rocío
                    plot([xRocTrueD(p) xRocTrueD(p)], [yRocD(p), Min], "Color", 'c'); hold on; % Línea entre Curva de Rocío y Lado Inferior
                    % Segunda Gráfica
                    subplot(2, 2, 3)
                    plot([xXYD(p + 1) xXYD(p + 1)], [1, xXYD(p + 1)], "Color", 'c'); hold on; % Línea entre Lado Superior y Y = X
               end  




     % Desarollo por residuo (Izquierda):      
     
     % Condición de Rehervidor:
     

     % PASO 1: Situación de Condensación.
          
     
     
          
          % Gráfica de Izquierda

          subplot(2, 2, 3)
          plot([xXYW(1) xXYW(1)], [yXYW(1), yEqW(1)])
          for p = 1 : length(yBurW) - 1
               subplot(2, 2, 3)
               plot([xEqW(p) xXYW(p + 1)], [yEqW(p) yXYW(p + 1)], "Color", [1.0 0.4 0.0]); hold on; % Línea entre Equilibrio y XY.
               plot([xXYW(p + 1) xRocW(p)], [yXYW(p + 1) 1], "Color", [1.0 0.4 0.0]); hold on; % Línea entre XY y Lado Superior

               subplot(2, 2, 1)
               plot([xRocW(p) xRocW(p)],[Min yRocW(p)], "Color", [1.0 0.4 0.0]); hold on; % Línea entre Lado Inferior y Curva de Rocío
               plot([xRocW(p) xBurTrueW(p)], [yRocW(p) yBurW(p)], "Color", [0.0 0.6 0.2]); hold on; % Línea entre Curva de Rocío y Curva de Burbuja
               plot([xBurTrueW(p) xBurTrueW(p)], [yBurW(p), Min], "Color", [0.6 0.0 0.4]); hold on; % Línea entre Curva de Rocío y Lado Inferior

               subplot(2, 2, 3)
               plot([xEqW(p + 1) xEqW(p + 1)], [1, yXYW(p + 2)], "Color", [0.6 0.0 0.4]); hold on; % Línea entre Lado Superior y Equilibrio

          end
    
          % ETAPA: Construcción de curva de Equilibrio
          
          % Recolección:
          for p = 1 : length(xXYD) - 2
               xXYDCorregido(p) = xXYD(length(xXYD) - p + 1); 
               yEqDCorregido(p) = yEqD(length(xXYD) - p);
          end
     
          OpX = [xXYW(1:length(xXYW) - 1) xXYDCorregido xXYD(2)]; OpY = [yEqW yEqDCorregido yEqD(1)];
     
          subplot(2, 2, 3)
          plot(OpX, OpY, 'k'); hold on;

     end

     % Etapa: Determinación de Etapas

     PuntosX(1) = xD;
     PuntosY(1) = yEqD(1);
     xa = PuntosX(1);
     ya = PuntosY(1);
     i = 0;
     L = 1;
     Etapas = 0;

     while xa > xW
          if ya > EquiY(nXY - i) % Verificación de que 'y_a' se encuentre debajo de un punto de equilibrio. La respuesta "Apropiada" es No.
               i = i + 1;  % La solución es revisar una siguiente posición:
          elseif ya < EquiY(nXY - i) && ya > EquiY(nXY - i - 1) % Verificación de que "y_a" se encuentre entre dos puntos de equilibrio sucesivos. La respuesta "Apropiada" es Sí:
               % Ecuación de Recta en Intervalo de Equilibrio Tomado:
                    m = (EquiY(nXY - i) - EquiY(nXY - i - 1)) / (EquiX(nXY - i) - EquiX(nXY - i - 1)); b = (EquiY(nXY - i) - m * EquiX(nXY - i));
                    LiEqY = @(x) m * x + b; LiEqX = @(y) (y - b) / m;
                    % y - y1 = m * (x - x1) -> y = m * x + (y1 - m * x1)
     
               % Transporte desde Línea Operatoria a Curva de Equilibrio:
                    xb = LiEqX(ya);

               % Transporte desde Curva de Equilibrio a Curva de Operación:
                    for j = 1 : length(OpX) - 1
                         if xb > OpX(j) && xb < OpX(j + 1) 
                              mOp = (OpY(j + 1) - OpY(j)) / (OpX(j + 1) - OpX(j)); bOp = (OpY(j) - mOp * OpX(j)); % Recta de Línea Operatoria
                              LiOpY = @(x) mOp * x + bOp; LiOpX = @(x) (y - bOp) / mOp;
                              
                              yb = LiOpY(xb);
                         end
                    end

               % Conteo de Coordenadas en Obtenidas:
                    L = L + 1;
                    PuntosX(L) = xb;
                    PuntosY(L) = yb;
               % Establecimiento de nuevo punto "a" para iniciar:
                    xa = xb;
                    ya = yb;           
                    
          else % Corrección en caso de que no se cumplan ninguna de las dos condiciones anteriores:
               i = i + 1;
          end 
     end
     
     for j = 1 : length(PuntosX) - 1
         subplot(2,2,4)
         % Dibujo de Recta Horizontal / Tendencia al Equilibrio:
         RecHorizonX = [PuntosX(j), PuntosX(j + 1)];
         RecHorizonY = [PuntosY(j) PuntosY(j)];
         plot(RecHorizonX, RecHorizonY, "Color", [0.0, 0.2, 1.0], "linewidth", 1.5);
         hold on;

         % Dibujo de Recta Vertical / Cumplimiento de Balance de Materia:
         RecVertiX = [PuntosX(j + 1) PuntosX(j + 1)];
         RecVertiY = [PuntosY(j) PuntosY(j + 1)];
         plot(RecVertiX, RecVertiY, "Color", [0.2 0.4 1.0], "linewidth", 1.5);
     
         % Conteo de Etapas:
         Etapas = Etapas + 1;
     end

     plot(OpX, OpY, 'k'); hold on;
     disp(Etapas);

