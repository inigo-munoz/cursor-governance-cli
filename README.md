# cursor-governance-cli

> CLI para instalar, verificar y actualizar la gobernanza de Cursor AI en proyectos de desarrollo.

Herramienta de línea de comandos que automatiza la gestión del sistema de gobernanza en proyectos reales. Instala el stack correcto según el tipo de proyecto, verifica que la gobernanza está vigente y actualiza las reglas cuando hay nuevas versiones.

---

## ¿Qué hace?

Sin el CLI, configurar la gobernanza en un proyecto nuevo significa copiar ficheros manualmente, actualizar rutas y asegurarse de que `.cursor/rules/` tiene los archivos correctos. Con el CLI, todo eso es un comando.

```bash
# Instalar gobernanza en un proyecto PrestaShop
cursor-governance install --stack prestashop8

# Verificar que la versión instalada está actualizada
cursor-governance verify

# Actualizar al último release
cursor-governance update

# Ver qué stacks hay disponibles
cursor-governance list
```

---

## Instalación

```bash
git clone https://github.com/inigo-munoz/cursor-governance-cli.git ~/.cursor-governance/cli
bash ~/.cursor-governance/cli/install.sh
```

Esto añade `cursor-governance` al PATH y deja el CLI disponible globalmente.

**Requisitos:**
- Bash
- Git
- SSH configurado para GitHub (para actualización automática de stacks)

---

## Cómo funciona

El CLI gestiona un directorio central en `~/.cursor-governance/` con la siguiente estructura:

```
~/.cursor-governance/
├── cli/                    # El propio CLI
└── stacks/
    ├── core/               # cursor-governance-core
    ├── prestashop8/        # cursor-governance-prestashop8
    ├── nodejs/             # cursor-governance-nodejs
    └── magento248/         # cursor-governance-magento248
```

Cuando instalas un stack en un proyecto, el CLI crea o actualiza `.cursor/rules/governance-stack.md` en la raíz del proyecto con las referencias a los ficheros de gobernanza del stack correspondiente. Cursor los carga automáticamente en cada sesión.

---

## Verificación de integridad

El CLI incluye un sistema de verificación por hash que comprueba que los ficheros de gobernanza instalados en el proyecto coinciden con la versión del repositorio:

```bash
cursor-governance verify
# ✅ cursor-governance-core v2.2.0 — OK
# ✅ cursor-governance-prestashop8 v1.3.0 — OK
# ⚠️  cursor-governance-nodejs — desactualizado (local: v1.3.0, remoto: v1.4.0)
```

---

## Estructura del repositorio

```
cursor-governance-cli/
├── bin/
│   └── cursor-governance        # Binario principal
├── rulesets/
│   └── prestashop/
│       └── security_patterns.sh # Patrones de seguridad para validación
├── ci/
│   └── ci-validate-pin.sh       # Validación en CI/CD
├── examples/
│   └── gitignore_global         # .gitignore recomendado
├── governance-organizativa.md   # Documentación de la gobernanza organizativa
└── install.sh                   # Script de instalación
```

---

## Integración con CI/CD

El CLI incluye un script para validar la gobernanza en pipelines de GitHub Actions:

```yaml
# .github/workflows/ci.yml
- name: Validate governance
  run: bash .cursor-governance/cli/ci/ci-validate-pin.sh
```

---

## Repositorios relacionados

| Repo | Descripción |
|---|---|
| [cursor-governance-core](https://github.com/inigo-munoz/cursor-governance-core) | Principios y framework base |
| [cursor-governance-prestashop8](https://github.com/inigo-munoz/cursor-governance-prestashop8) | Stack PrestaShop 8 |
| [cursor-governance-nodejs](https://github.com/inigo-munoz/cursor-governance-nodejs) | Stack Node.js |
| [cursor-governance-magento248](https://github.com/inigo-munoz/cursor-governance-magento248) | Stack Magento 2.4 |

---

## Autor

**Íñigo Muñoz Jiménez** — Backend Developer especializado en ecommerce e integraciones empresariales.

- GitHub: [@inigo-munoz](https://github.com/inigo-munoz)
- LinkedIn: [imjdev](https://linkedin.com/in/imjdev)
- Email: inigomunozjimenez@gmail.com

---

## Licencia

MIT — libre de usar, adaptar y distribuir con atribución.
