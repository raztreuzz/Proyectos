#!/bin/bash

# Configuración
CONFIG_FILE="nms_config.cfg"
DISCORD_WEBHOOK=""
DIARY_FILE="nms_diary.log"
OBJECTIVES_FILE="nms_objectives.log"
SHIPS_FILE="nms_ships.log"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Inicializar archivos
touch "$DIARY_FILE" "$OBJECTIVES_FILE" "$SHIPS_FILE"

# Función para enviar mensajes a Caspian (Discord)
send_to_caspian() {
    local message="$1"
    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -H "Content-Type: application/json" -d "{\"content\":\"$message\"}" "$DISCORD_WEBHOOK" >/dev/null 2>&1
    fi
}

# Función para cargar configuración
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo -e "${YELLOW}Configuración no encontrada. Creando nueva...${NC}"
        read -p "¿Configurar webhook Caspian? (s/n): " setup_caspian
        if [[ "$setup_caspian" == "s" ]]; then
            read -p "Ingresa tu Webhook de Discord (Caspian): " DISCORD_WEBHOOK
            echo "DISCORD_WEBHOOK='$DISCORD_WEBHOOK'" > "$CONFIG_FILE"
            send_to_caspian "🔵 **Caspian Online**: ¡Asistente de NMS conectado!"
            echo -e "${GREEN}✓ Configuración guardada${NC}"
        fi
    fi
}

# Banner mejorado
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "   ▐ ▄ ▄▄▄ .▄▄▄▄▄ ▄ .▄▄▄▄▄.▄▄ · "
    echo "  •█▌▐█▀▄.▀·•██▀▄▀▪▀▄.▀•██▪▐█ "
    echo "  ▐█▐▐▌▐▀▀▪▄▐█.▪▄▀▀▀▄ ▐█.▪▐█▌▐█"
    echo "  ██▐█▌▐█▄▄▌▐█▌·▐█▄█▌▐█▌·▐█▐▐▌"
    echo "  ▀▀ █▪ ▀▀▀ ▀▀▀  ▀▀▀ ▀▀▀ ▀▀ ▀▪"
    echo -e "${CYAN}   Asistente Pro para No Man's Sky v3.0${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════${NC}"
}

# 1. Wiki Search con Registro en Discord
wiki_search() {
    show_banner
    echo -e "${YELLOW}== 🔍 Buscar en la Wiki ==${NC}"
    read -p "Ingresa tu búsqueda: " query
    xdg-open "https://nomanssky.fandom.com/es/wiki/Special:Search?query=${query}"
    send_to_caspian "📚 **Búsqueda en Wiki**: \"$query\""
}

# 2. Calculadora de Comercio Mejorada
trade_calculator() {
    show_banner
    echo -e "${YELLOW}== 💰 Calculadora de Comercio ==${NC}"
    
    PS3="Selecciona un recurso (o escribe 'otro'): "
    select resource in "Cobalto" "Emeril" "Oro" "Ferrita" "Otro"; do
        case $resource in
            "Otro") read -p "Nombre del recurso: " resource; break ;;
            *) break ;;
        esac
    done

    read -p "Precio de compra por unidad: " buy_price
    read -p "Precio de venta por unidad: " sell_price
    read -p "Cantidad a vender: " units

    profit=$(( (sell_price - buy_price) * units ))
    echo -e "${GREEN}Ganancia estimada: ${profit} unidades${NC}"

    trade_msg="🛒 **Transacción**: ${units}u de ${resource} | Ganancia: ${profit}u"
    echo "[$(date +'%Y-%m-%d %H:%M')] $trade_msg" >> "$DIARY_FILE"
    send_to_caspian "$trade_msg"
    
    read -p "Presiona Enter para continuar..."
}

# 3. Diario de Exploración Mejorado
explorer_diary() {
    while true; do
        show_banner
        echo -e "${YELLOW}== 📔 Diario de Exploración ==${NC}"
        echo "1. 📝 Nueva entrada"
        echo "2. 📜 Ver diario"
        echo "3. 🌌 Compartir último descubrimiento"
        echo "4. 🏠 Volver"
        read -p "Opción (1-4): " diary_choice

        case $diary_choice in
            1)
                echo -e "${CYAN}---- Nueva Entrada ----${NC}"
                read -p "Nombre del planeta/sistema: " planet
                read -p "Coordenadas (opcional): " coords
                read -p "Tipo de planeta: " planet_type
                read -p "Recursos importantes: " resources
                read -p "Notas adicionales: " notes
                
                entry="[$(date +'%Y-%m-%d %H:%M')] 🌍 ${planet} | 📌 ${coords} | 🪐 ${planet_type} | 💎 ${resources} | 📝 ${notes}"
                echo "$entry" >> "$DIARY_FILE"
                
                echo -e "${GREEN}✓ Entrada guardada${NC}"
                send_to_caspian "🪐 **Nuevo planeta registrado**: ${planet} (${planet_type})"
                sleep 1
                ;;
            2)
                echo -e "${CYAN}---- Diario Completo ----${NC}"
                cat "$DIARY_FILE" | less
                ;;
            3)
                last_entry=$(tail -n 1 "$DIARY_FILE")
                if [ -n "$last_entry" ]; then
                    send_to_caspian "📜 **Último descubrimiento**: $last_entry"
                    echo -e "${GREEN}✓ Entrada compartida con Caspian${NC}"
                else
                    echo -e "${RED}No hay entradas en el diario${NC}"
                fi
                sleep 1
                ;;
            4) break ;;
            *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
    done
}

# 4. Generador de Naves con Registro en Discord
ship_name_generator() {
    show_banner
    echo -e "${YELLOW}== 🛸 Generador de Naves ==${NC}"
    
    PS3="Selecciona la clase: "
    select ship_class in "C 🟢" "B 🔵" "A 🟣" "S 🟡"; do
        case $ship_class in
            *🟢*) ship_class="C"; break ;;
            *🔵*) ship_class="B"; break ;;
            *🟣*) ship_class="A"; break ;;
            *🟡*) ship_class="S"; break ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
    done

    PS3="Selecciona el tipo: "
    select ship_type in "Carga 📦" "Combate ⚔️" "Exploración 🚀" "Exótica ✨"; do
        case $ship_type in
            *📦*) ship_type="Carga"; break ;;
            *⚔️*) ship_type="Combate"; break ;;
            *🚀*) ship_type="Exploración"; break ;;
            *✨*) ship_type="Exótica"; break ;;
            *) echo -e "${RED}Opción inválida${NC}" ;;
        esac
    done

    prefixes=("Vórtice" "Éter" "Infinito" "Némesis" "Eclipse" "Astral" "Quantum")
    suffixes=(" de la Perdición" " Estelar" " del Abismo" " Cuántica" " de Atlas" " Celestial")
    random_name="${prefixes[$RANDOM % ${#prefixes[@]}]}${suffixes[$RANDOM % ${#suffixes[@]}]}"
    
    echo -e "\n${CYAN}    |-[${PURPLE}🚀${CYAN}]> ${GREEN}${random_name}${NC}"
    echo -e "${BLUE}    ├─ Clase: ${ship_class}"
    echo -e "    └─ Tipo: ${ship_type}${NC}\n"

    ship_entry="[$(date +'%Y-%m-%d')] ${random_name} | Clase: ${ship_class} | Tipo: ${ship_type}"
    echo "$ship_entry" >> "$SHIPS_FILE"
    
    echo "1. Guardar en objetivos"
    echo "2. Compartir con Caspian"
    echo "3. Ambos"
    read -p "Opción (1-3): " save_choice
    
    case $save_choice in
        1) 
            echo "[ ] Encontrar nave: ${random_name} (Clase ${ship_class}, ${ship_type})" >> "$OBJECTIVES_FILE"
            echo -e "${GREEN}✓ Añadido a objetivos${NC}"
            ;;
        2)
            send_to_caspian "🛸 **Nueva nave generada**: ${random_name} (Clase ${ship_class}, ${ship_type})"
            ;;
        3)
            echo "[ ] Encontrar nave: ${random_name} (Clase ${ship_class}, ${ship_type})" >> "$OBJECTIVES_FILE"
            send_to_caspian "🛸 **Nave añadida a objetivos**: ${random_name}"
            echo -e "${GREEN}✓ Guardado y compartido${NC}"
            ;;
    esac
    read -p "Presiona Enter para continuar..."
}

# 5. Gestor de Objetivos Mejorado
objectives_manager() {
    while true; do
        show_banner
        echo -e "${YELLOW}== 🎯 Gestor de Objetivos ==${NC}"
        echo "1. 📝 Añadir objetivo"
        echo "2. ✅ Marcar como completado"
        echo "3. 📜 Ver objetivos"
        echo "4. 🗑️ Eliminar objetivo"
        echo "5. 📢 Compartir objetivos"
        echo "6. 🏠 Volver"
        read -p "Opción (1-6): " obj_choice

        case $obj_choice in
            1)
                read -p "Nuevo objetivo: " new_obj
                echo "[ ] ${new_obj}" >> "$OBJECTIVES_FILE"
                echo -e "${GREEN}✓ Objetivo añadido${NC}"
                send_to_caspian "🎯 **Nuevo objetivo**: ${new_obj}"
                sleep 1
                ;;
            2)
                echo -e "${CYAN}---- Objetivos Pendientes ----${NC}"
                grep -n "^\[ \]" "$OBJECTIVES_FILE" || echo "No hay objetivos pendientes."
                read -p "Número del objetivo completado: " obj_num
                sed -i "${obj_num}s/^\[ \]/[✓]/" "$OBJECTIVES_FILE"
                completed_obj=$(sed -n "${obj_num}p" "$OBJECTIVES_FILE")
                echo -e "${GREEN}✓ Objetivo completado${NC}"
                send_to_caspian "✅ **Objetivo completado**: ${completed_obj}"
                sleep 1
                ;;
            3)
                echo -e "${CYAN}---- Todos los Objetivos ----${NC}"
                cat "$OBJECTIVES_FILE" | less
                ;;
            4)
                echo -e "${CYAN}---- Objetivos ----${NC}"
                nl -ba "$OBJECTIVES_FILE"
                read -p "Número del objetivo a eliminar: " del_num
                deleted_obj=$(sed -n "${del_num}p" "$OBJECTIVES_FILE")
                sed -i "${del_num}d" "$OBJECTIVES_FILE"
                echo -e "${GREEN}✓ Objetivo eliminado${NC}"
                send_to_caspian "❌ **Objetivo eliminado**: ${deleted_obj}"
                sleep 1
                ;;
            5)
                objectives_list=$(cat "$OBJECTIVES_FILE")
                send_to_caspian "📋 **Lista de Objetivos**:\n${objectives_list}"
                echo -e "${GREEN}✓ Objetivos compartidos${NC}"
                sleep 1
                ;;
            6) break ;;
            *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
    done
}

# 6. Notificaciones Discord Mejoradas
discord_notifications() {
    while true; do
        show_banner
        echo -e "${YELLOW}== 📢 Caspian (Discord) ==${NC}"
        echo "1. Enviar mensaje personalizado"
        echo "2. Notificar descubrimiento"
        echo "3. Compartir última nave generada"
        echo "4. Estado actual"
        echo "5. Volver"
        read -p "Opción (1-5): " discord_choice

        case $discord_choice in
            1)
                read -p "Mensaje: " message
                send_to_caspian "💬 **Mensaje personalizado**: $message"
                echo -e "${GREEN}✓ Mensaje enviado${NC}"
                ;;
            2)
                read -p "Planeta/sistema: " location
                read -p "Descripción: " description
                send_to_caspian "🪐 **Nuevo descubrimiento**: **${location}** - ${description}"
                echo -e "${GREEN}✓ Notificación enviada${NC}"
                ;;
            3)
                last_ship=$(tail -n 1 "$SHIPS_FILE")
                if [ -n "$last_ship" ]; then
                    send_to_caspian "🛸 **Última nave generada**: $last_ship"
                    echo -e "${GREEN}✓ Nave compartida${NC}"
                else
                    echo -e "${RED}No hay naves registradas${NC}"
                fi
                ;;
            4)
                stats="📊 **Estadísticas**\n"
                stats+="• 📔 Entradas en diario: $(wc -l < "$DIARY_FILE")\n"
                stats+="• 🎯 Objetivos: $(grep -c "^\[ \]" "$OBJECTIVES_FILE") pendientes\n"
                stats+="• 🛸 Naves registradas: $(wc -l < "$SHIPS_FILE")"
                send_to_caspian "$stats"
                echo -e "${GREEN}✓ Estadísticas enviadas${NC}"
                ;;
            5) break ;;
            *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
        sleep 1
    done
}

# 7. Configuración Mejorada
config_menu() {
    while true; do
        show_banner
        echo -e "${YELLOW}== ⚙️ Configuración ==${NC}"
        echo "1. Configurar webhook Caspian"
        echo "2. Ver archivos de datos"
        echo "3. Exportar datos"
        echo "4. Borrar datos"
        echo "5. Volver"
        read -p "Opción (1-5): " config_choice

        case $config_choice in
            1)
                read -p "Nuevo Webhook: " new_webhook
                DISCORD_WEBHOOK="$new_webhook"
                echo "DISCORD_WEBHOOK='$new_webhook'" > "$CONFIG_FILE"
                send_to_caspian "⚙️ **Configuración actualizada**: Nuevo webhook configurado"
                echo -e "${GREEN}✓ Webhook actualizado${NC}"
                sleep 1
                ;;
            2)
                echo -e "${CYAN}---- Diario (últimas 3 entradas) ----${NC}"
                tail -n 3 "$DIARY_FILE"
                echo -e "\n${CYAN}---- Objetivos Pendientes ----${NC}"
                grep "^\[ \]" "$OBJECTIVES_FILE"
                echo -e "\n${CYAN}---- Naves Registradas (últimas 3) ----${NC}"
                tail -n 3 "$SHIPS_FILE"
                read -p "Presiona Enter para continuar..."
                ;;
            3)
                tar -czf "nms_backup_$(date +%Y%m%d).tar.gz" "$DIARY_FILE" "$OBJECTIVES_FILE" "$SHIPS_FILE"
                echo -e "${GREEN}✓ Backup creado: nms_backup_$(date +%Y%m%d).tar.gz${NC}"
                sleep 1
                ;;
            4)
                read -p "¿Borrar TODOS los datos? (s/n): " confirm
                if [[ "$confirm" == "s" ]]; then
                    > "$DIARY_FILE"
                    > "$OBJECTIVES_FILE"
                    > "$SHIPS_FILE"
                    echo -e "${GREEN}✓ Todos los datos borrados${NC}"
                    send_to_caspian "⚠️ **Todos los datos han sido borrados**"
                fi
                sleep 1
                ;;
            5) break ;;
            *) echo -e "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
    done
}

# Menú principal
main_menu() {
    while true; do
        show_banner
        echo -e "${GREEN}1. 📖 Buscar en la Wiki"
        echo "2. 💰 Calculadora de Comercio"
        echo "3. 📔 Diario de Exploración"
        echo "4. 🛸 Generador de Nombres de Naves"
        echo "5. 🎯 Gestor de Objetivos"
        echo "6. 📢 Notificaciones Discord"
        echo "7. ⚙️ Configuración"
        echo "8. 🚪 Salir"
        echo -e "${BLUE}══════════════════════════════════════════════${NC}"
        read -p "Elige una opción (1-8): " choice

        case $choice in
            1) wiki_search ;;
            2) trade_calculator ;;
            3) explorer_diary ;;
            4) ship_name_generator ;;
            5) objectives_manager ;;
            6) discord_notifications ;;
            7) config_menu ;;
            8) exit 0 ;;
            *) echo -e "${RED}Opción inválida. Inténtalo de nuevo.${NC}"; sleep 1 ;;
        esac
    done
}

# ===== Inicio =====
load_config
show_banner
echo -e "${GREEN}Conectado a Caspian: $( [ -n "$DISCORD_WEBHOOK" ] && echo "✅" || echo "❌" )${NC}"
sleep 1
main_menu  # Llamada al menú principal al final