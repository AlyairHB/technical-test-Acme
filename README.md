# Technical Test - Acme

## Descripción

Este proyecto implementa un componente Aura en Salesforce que permite crear Contactos con RecordTypes por región. Al crear un Contacto, un Trigger automáticamente genera una Oportunidad asociada a la misma Cuenta.

## Componentes del Proyecto

### Aura Component: `createContactAura`

Componente Lightning para la creación de Contactos con selección de región.

**Archivos:**
- `createContactAura.cmp` - Componente principal con el formulario
- `createContactAuraController.js` - Controlador del componente
- `createContactAuraHelper.js` - Helper con la lógica de creación

**Funcionalidades:**
- Selección de región (Americas / Europe) via radio buttons
- Campos: First Name, Last Name, Account (con selector visual)
- Mensajes de éxito/error

### Apex Controller: `createContactControllerAura`

Clase AuraEnabled que maneja la creación del Contacto en Salesforce.

### Trigger: `contactTrigger`

Trigger en el objeto Contact que ejecuta lógica en dos eventos:

#### After Insert
- Consulta los RecordTypes de los contactos insertados
- Mapea RecordTypes a regiones (`Americas_Contact` → `Americas`, `Europe_Contact` → `Europe`)
- Crea una Oportunidad por cada Contacto con:
  - **Name**: `[FirstName] [LastName]`
  - **AccountId**: Mismo que el Contacto
  - **StageName**: `Prospecting`
  - **CloseDate**: Hoy + 30 días
  - **Region__c**: Región correspondiente

#### After Update
- Detecta cambios en el nombre del Contacto
- Actualiza el nombre de las Oportunidades asociadas con el mismo AccountId y nombre anterior
- Usa `triggerHandler` para prevenir recursión

### Trigger Handler: `triggerHandler`

Clase utilitaria con flags estáticos para prevenir triggers recursivos:
- `contactRunning`: Evita loop en contactTrigger → opportunityTrigger
- `opportunityTRunning`: Evita loop en opportunityTrigger → contactTrigger

## Flujo

```
┌─────────────────────────────────────────────────────────────┐
│                    Usuario llena formulario                 │
│  - First Name: Juan                                         │
│  - Last Name: Pérez                                        │
│  - Region: Americas                                        │
│  - Account: Acme Corp                                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         createContactAuraHelper.createContact()              │
│         - Invoca Apex Action: createContact()               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│         createContactControllerAura.createContact()         │
│         - Obtiene RecordTypeId por DeveloperName           │
│         - Crea Contact con AccountId                       │
│         - INSERT Contact                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              contactTrigger (after insert)                 │
│         - Obtiene RecordTypes consultando por Id           │
│         - Mapea region desde rtRegion map                  │
│         - Crea Opportunity por cada Contact c/AccountId   │
│         - INSERT Opportunities                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Resultado Final                           │
│  Contact: Juan Pérez (Americas_Contact) → Account: Acme    │
│  Opportunity: Juan Pérez (Prospecting, CloseDate+30)        │
└─────────────────────────────────────────────────────────────┘
```

## Requisitos

### RecordTypes Requeridos

Crear los siguientes RecordTypes para Contact:
- `Americas_Contact` (Label: "Americas Contact")
- `Europe_Contact` (Label: "Europe Contact")

### Campo Custom

- `Region__c` en Opportunity (tipo Text, 255 caracteres)

## Instalación

1. Desplegar el código usando Salesforce CLI:
   ```bash
   sf project deploy start -d force-app
   ```

2. Crear RecordTypes en Salesforce:
   - Ir a Setup → Object Manager → Contact → Record Types
   - Crear `Americas_Contact` y `Europe_Contact`

3. Crear campo custom:
   - Ir a Setup → Object Manager → Opportunity → Fields & Relationships
   - Crear `Region__c` como Text

## Uso

1. Agregar el componente `createContactAura` a una Lightning Page
2. Completar el formulario:
   - Seleccionar región (Americas o Europe)
   - Ingresar First Name y Last Name
   - Buscar y seleccionar Account
3. Click en "Create Contact"
4. Verificar que se creó el Contacto y la Oportunidad asociada
