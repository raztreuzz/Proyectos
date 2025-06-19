#!/bin/bash

# Focus Sprint Script - Caspian Efficiency++
SPRINT_DURATION=1500   # 25 minutos
BREAK_DURATION=300     # 5 minutos
LONG_BREAK_DURATION=900 # 15 minutos al final
SPRINTS_TOTAL=4

function notify() {
    notify-send "⏱️ $1" "$2"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
}

clear
echo "🔁 Iniciando Focus Sprint - Caspian Keys"
for (( i=1; i<=$SPRINTS_TOTAL; i++ ))
do
    echo "🎯 Sprint $i de $SPRINTS_TOTAL - Enfoque total por 25 minutos."
    notify "Sprint $i iniciado" "Enfócate en UNA tarea."
    sleep $SPRINT_DURATION

    if [ $i -lt $SPRINTS_TOTAL ]; then
        echo "☕ Descanso corto - 5 minutos."
        notify "Descanso corto" "Levántate, respira, estírate."
        sleep $BREAK_DURATION
    else
        echo "🏁 Todos los sprints completados. Descanso largo - 15 minutos."
        notify "¡Bien hecho!" "Focus completo. Toma un break de 15 minutos."
        sleep $LONG_BREAK_DURATION
    fi
done

echo "✅ Focus Sprint terminado. Vuelve cuando estés listo para otro ciclo."
notify "Focus Sprint terminado" "Logro desbloqueado: Enfoque nivel 1."
