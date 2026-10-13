# Gobernanza Organizativa

Cómo gestionar actualizaciones de governance a nivel de equipo.

---

## Pregunta clave: ¿Quién decide cuándo hacer `bump`?

### Modelo recomendado: **Centralizado con autonomía local**

| Rol | Responsabilidad |
|-----|-----------------|
| **Governance Owner** (1 persona) | Publica nuevas versiones, define política de soporte |
| **Tech Lead de proyecto** | Decide cuándo hacer bump en su proyecto |
| **Developer** | Ejecuta apply, reporta problemas |

---

## Ciclo de vida de versiones

### Publicación (Governance Owner)

```
1. Desarrolla cambios en rama feature
2. PR → review → merge a main
3. Tag: git tag vX.Y.Z
4. Notifica al equipo (Slack, email)
```

### Adopción (Tech Lead)

```
1. Recibe notificación de nueva versión
2. Evalúa changelog
3. Decide: adoptar ahora / después / nunca
4. Si adopta:
   - cursor-governance update
   - cursor-governance bump --core vX.Y.Z --stack vX.Y.Z
   - cursor-governance apply
   - Prueba
   - PR con nuevo pin
```

### Aplicación (Developer)

```
1. git pull (recibe nuevo pin)
2. cursor-governance apply
3. Trabaja normalmente
```

---

## Política de soporte de versiones

### Modelo N-1 (recomendado)

| Versión | Estado | Soporte |
|---------|--------|---------|
| vX.Y.Z (latest) | ✅ Actual | Bugs + features |
| vX.Y.Z-1 | ⚠️ Anterior | Solo bugs críticos |
| Anteriores | ❌ Deprecated | Sin soporte |

### Ejemplo concreto

```
v2.1.0 (latest)  → Soporte completo
v2.0.5           → Solo bugs críticos
v2.0.4 y antes   → Sin soporte
```

### Consecuencias

- Proyectos en versión deprecated **deben** actualizar
- CI puede añadir warning (no bloqueo) si versión es deprecated
- Governance Owner puede forzar actualización en casos críticos (seguridad)

---

## Calendario de actualizaciones

### Opción A: Ciclo fijo (mensual)

```
Semana 1: Governance Owner publica nueva versión
Semana 2: Tech Leads evalúan y deciden
Semana 3-4: PRs de actualización
```

**Ventaja**: Predecible
**Desventaja**: Puede retrasar fixes críticos

### Opción B: Continuo con ventanas

```
- Versiones menores: cuando estén listas
- Versiones mayores: trimestral
- Fixes de seguridad: inmediato
```

**Ventaja**: Flexible
**Desventaja**: Más coordinación necesaria

### Recomendación

**Opción B para equipos pequeños (<10 devs)**
**Opción A para equipos grandes (>10 devs)**

---

## Divergencia entre proyectos

### Es aceptable que proyectos estén en versiones diferentes?

**Sí, temporalmente.**

Reglas:
1. Máximo 2 versiones de diferencia (N-2)
2. Máximo 3 meses sin actualizar
3. Proyectos críticos deben estar siempre en latest

### Cómo detectar divergencia

```bash
# Script para auditar todos los proyectos
for project in /proyectos/*; do
  if [ -f "$project/.cursor-governance.yml" ]; then
    echo "$project: $(grep stack_version $project/.cursor-governance.yml)"
  fi
done
```

### Dashboard (opcional)

Si tienes muchos proyectos, considera:
- Script que recopila versiones de todos los repos
- Genera informe semanal
- Envía a Slack

---

## Comunicación de cambios

### Changelog obligatorio

Cada versión debe tener changelog claro:

```markdown
## v2.1.0 — 2024-03-15

### Añadido
- Nueva regla de seguridad para APIs

### Modificado
- Actualizado patrón de conexión a BD

### Breaking changes
- NINGUNO (o lista específica)
```

### Canales de comunicación

| Tipo de cambio | Canal | Urgencia |
|----------------|-------|----------|
| Nueva versión | Slack #governance | Normal |
| Breaking change | Email + Slack | Alta |
| Fix de seguridad | Email + llamada | Urgente |

---

## Roles detallados

### Governance Owner

**Quién**: Típicamente el arquitecto o senior del equipo

**Responsabilidades**:
- Mantiene repos de governance (core, prestashop, magento)
- Publica nuevas versiones
- Define política de soporte
- Resuelve conflictos entre proyectos

**Tiempo estimado**: 2-4 horas/semana

### Tech Lead de proyecto

**Responsabilidades**:
- Decide cuándo actualizar su proyecto
- Revisa changelog antes de bump
- Asegura que su equipo hace apply tras pull

### Developer

**Responsabilidades**:
- Ejecuta apply cuando cambia el pin
- Reporta problemas con governance
- NO modifica el pin sin aprobación del lead

---

## Checklist de adopción

### Para empezar a usar governance en un equipo

- [ ] Nombrar Governance Owner
- [ ] Instalar CLI en todas las máquinas
- [ ] Crear pin inicial en todos los proyectos
- [ ] Añadir ci-validate-pin.sh a pipelines
- [ ] Configurar canal Slack #governance
- [ ] Definir política de soporte (N-1 o N-2)
- [ ] Definir ciclo de actualizaciones (fijo o continuo)
- [ ] Documentar proceso de escalación

---

## Escalación de problemas

### Problema con una regla

```
1. Developer reporta en Slack
2. Tech Lead evalúa
3. Si es bug → Issue en repo governance
4. Governance Owner prioriza y resuelve
```

### Conflicto entre proyectos

```
1. Tech Leads exponen necesidades
2. Governance Owner media
3. Si no hay acuerdo → Decisión del arquitecto
```

### Urgencia de seguridad

```
1. Governance Owner publica fix inmediato
2. Email a todos los Tech Leads
3. Deadline de 48h para bump en proyectos críticos
```

---

## Métricas sugeridas

| Métrica | Objetivo | Cómo medir |
|---------|----------|------------|
| Tiempo medio de adopción | < 1 semana | Fecha de tag → fecha de PRs |
| Proyectos en versión deprecated | 0% | Script de auditoría |
| Incidentes por governance desactualizado | 0 | Postmortems |
| Tiempo de resolve de bugs governance | < 3 días | Issues en repo |

---

## Resumen ejecutivo

1. **Governance Owner** publica versiones
2. **Tech Leads** deciden cuándo adoptar
3. **Developers** ejecutan apply
4. **CI** valida que el pin existe y es válido
5. **Política N-1**: máximo 1 versión de retraso
6. **Comunicación clara**: changelog + Slack + email para breaking changes
