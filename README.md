# A* Modificado

En la carpeta `src` están los siguientes archivos:

1. `a_star.jl` implementa A* modificado
2. `main.jl` esta la función principal para resolver los problemas de prueba, asi como la función heurística.
3. `plot-malla.jl` implementa funciones para graficar los grafos.
4. `problemas-de-prueba.jl` contiene funciones para generar instancias de prueba para probar A* modificado
5. `tools.jl` implementa funciones auxiliares.

La función `main` requiere un parámetro el cual indica el problema de prueba a resolver (`:espiral`,`:seno`,`:parabola`) y tres parámetros con palabras clave (opcionales):

1. `seed_malla` un número entero que cambia la semilla para generar una malla incompleta aleatoria (1 predeterminado)
2. `penalización` número entero referente al factor de penalización en la función heurística (500 predeterminado)
3. `genera_gif` genera una animación si su valor es true (`false` predeterminado)


## Ejemplo

Hallar ruta para la trayectoria con forma de espiral con factor de penalización igual al 500 sin animación con semilla fijada en 1.
```julia
main(:espiral, seed_malla = 1, penalización = 500, genera_gif=false)
```

**Importante:** <span style="color:  #99004d;">La primera vez que llame la función main, es problable que demore un poco en ejecutarse, la segura vez será mucho más rapido debido a que Julia compila funciones la primera vez que éstas son llamadas.</span>
