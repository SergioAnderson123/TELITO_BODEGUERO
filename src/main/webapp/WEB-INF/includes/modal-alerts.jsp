<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
    Componente de Modales Personalizados
    Reemplaza los alerts y confirms nativos del navegador
--%>

<!-- Modal de Alerta -->
<div class="modal fade" id="customAlertModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title d-flex align-items-center" id="customAlertTitle">
                    <i class="fas fa-info-circle me-2 text-info" id="customAlertIcon"></i>
                    <span id="customAlertTitleText">Información</span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customAlertMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-primary" data-bs-dismiss="modal">
                    <i class="fas fa-check me-1"></i> Entendido
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Confirmación -->
<div class="modal fade" id="customConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title d-flex align-items-center">
                    <i class="fas fa-question-circle me-2 text-warning"></i>
                    <span id="customConfirmTitle">Confirmar acción</span>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customConfirmMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                    <i class="fas fa-times me-1"></i> Cancelar
                </button>
                <button type="button" class="btn btn-primary" id="customConfirmBtn">
                    <i class="fas fa-check me-1"></i> Aceptar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Confirmación de Eliminación (Diseño Destructivo) -->
<div class="modal fade" id="customDeleteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px; overflow: hidden;">
            <div class="modal-header border-0 pb-3" style="background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); padding: 1.75rem 2rem;">
                <div class="d-flex align-items-center w-100">
                    <div class="delete-icon-container me-3" style="width: 56px; height: 56px; background: rgba(255, 255, 255, 0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; backdrop-filter: blur(10px);">
                        <i class="fas fa-exclamation-triangle text-white" style="font-size: 1.75rem;"></i>
                    </div>
                    <div class="flex-grow-1">
                        <h5 class="modal-title text-white mb-0" id="customDeleteTitle" style="font-size: 1.35rem; font-weight: 700; letter-spacing: 0.3px;">
                            Confirmar eliminación
                        </h5>
                        <small class="text-white-50" style="font-size: 0.85rem; opacity: 0.9;">Acción irreversible</small>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close" style="opacity: 0.9; font-size: 1.2rem;"></button>
                </div>
            </div>
            <div class="modal-body" style="padding: 2rem;">
                <div class="text-center mb-4">
                    <div class="warning-icon-large mb-3" style="width: 80px; height: 80px; margin: 0 auto; background: linear-gradient(135deg, #fff5f5 0%, #ffe5e5 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 3px solid #fee; box-shadow: 0 4px 12px rgba(220, 53, 69, 0.15);">
                        <i class="fas fa-trash-alt text-danger" style="font-size: 2.5rem;"></i>
                    </div>
                </div>
                <p id="customDeleteMessage" class="text-center mb-0" style="font-size: 1.05rem; line-height: 1.7; color: #495057; font-weight: 500;">
                    ¿Estás seguro de que deseas eliminar este usuario?
                </p>
                <div class="alert alert-danger border-0 mt-4 mb-0" style="background: linear-gradient(135deg, #fff5f5 0%, #ffe5e5 100%); border-left: 4px solid #dc3545 !important; border-radius: 8px; padding: 1rem;">
                    <div class="d-flex align-items-start">
                        <i class="fas fa-info-circle me-2 mt-1" style="color: #dc3545; font-size: 1.1rem;"></i>
                        <div>
                            <strong style="color: #c82333; font-size: 0.95rem;">Advertencia:</strong>
                            <p class="mb-0 mt-1" style="color: #721c24; font-size: 0.9rem; line-height: 1.6;">
                                Esta acción no se puede deshacer. Todos los datos asociados a este usuario serán eliminados permanentemente del sistema.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 pt-0" style="padding: 1.5rem 2rem 2rem 2rem; background: #f8f9fa;">
                <button type="button" class="btn btn-sm btn-light border-2 fw-semibold" data-bs-dismiss="modal" style="min-width: 110px; padding: 0.5rem 1rem; border-color: #dee2e6 !important; color: #6c757d; transition: all 0.3s ease;" onmouseover="this.style.background='#e9ecef'; this.style.borderColor='#adb5bd';" onmouseout="this.style.background='#fff'; this.style.borderColor='#dee2e6';">
                    <i class="fas fa-times me-2"></i>Cancelar
                </button>
                <button type="button" class="btn btn-sm fw-semibold text-white" id="customDeleteBtn" style="min-width: 110px; padding: 0.5rem 1rem; background: linear-gradient(135deg, #dc3545 0%, #c82333 100%); border: none; box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4); transition: all 0.3s ease;" onmouseover="this.style.transform='translateY(-2px)'; this.style.boxShadow='0 6px 16px rgba(220, 53, 69, 0.5)';" onmouseout="this.style.transform='translateY(0)'; this.style.boxShadow='0 4px 12px rgba(220, 53, 69, 0.4)';">
                    <i class="fas fa-trash-alt me-2"></i>Eliminar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Éxito -->
<div class="modal fade" id="customSuccessModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0 bg-success text-white">
                <h5 class="modal-title d-flex align-items-center">
                    <i class="fas fa-check-circle me-2"></i>
                    <span>¡Éxito!</span>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customSuccessMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-success" data-bs-dismiss="modal">
                    <i class="fas fa-check me-1"></i> Aceptar
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Modal de Error -->
<div class="modal fade" id="customErrorModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0 bg-danger text-white">
                <h5 class="modal-title d-flex align-items-center">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <span>Error</span>
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p id="customErrorMessage" class="mb-0"></p>
            </div>
            <div class="modal-footer border-0">
                <button type="button" class="btn btn-danger" data-bs-dismiss="modal">
                    <i class="fas fa-times me-1"></i> Cerrar
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .modal-content {
        border-radius: 15px;
        overflow: hidden;
    }
    .modal-header {
        padding: 1.5rem;
    }
    .modal-body {
        padding: 1.5rem;
        font-size: 1rem;
    }
    .modal-footer {
        padding: 1rem 1.5rem;
    }
    
    /* Animación de entrada para el modal de eliminación */
    #customDeleteModal .modal-content {
        animation: slideInDown 0.3s ease-out;
    }
    
    @keyframes slideInDown {
        from {
            opacity: 0;
            transform: translateY(-30px) scale(0.95);
        }
        to {
            opacity: 1;
            transform: translateY(0) scale(1);
        }
    }
    
    /* Efecto de pulso en el icono de advertencia */
    .warning-icon-large {
        animation: pulse 2s ease-in-out infinite;
    }
    
    @keyframes pulse {
        0%, 100% {
            transform: scale(1);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.15);
        }
        50% {
            transform: scale(1.05);
            box-shadow: 0 6px 20px rgba(220, 53, 69, 0.25);
        }
    }
</style>

<script>
    // Variables globales para las instancias de modales (reutilización)
    let alertModalInstance = null;
    let confirmModalInstance = null;
    let successModalInstance = null;
    let errorModalInstance = null;
    let deleteModalInstance = null;
    
    // Función para obtener o crear instancia del modal de alerta
    function getAlertModal() {
        if (!alertModalInstance) {
            const modalElement = document.getElementById('customAlertModal');
            alertModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return alertModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de confirmación
    function getConfirmModal() {
        if (!confirmModalInstance) {
            const modalElement = document.getElementById('customConfirmModal');
            confirmModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return confirmModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de éxito
    function getSuccessModal() {
        if (!successModalInstance) {
            const modalElement = document.getElementById('customSuccessModal');
            successModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return successModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de error
    function getErrorModal() {
        if (!errorModalInstance) {
            const modalElement = document.getElementById('customErrorModal');
            errorModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return errorModalInstance;
    }
    
    // Función para obtener o crear instancia del modal de eliminación
    function getDeleteModal() {
        if (!deleteModalInstance) {
            const modalElement = document.getElementById('customDeleteModal');
            deleteModalInstance = bootstrap.Modal.getOrCreateInstance(modalElement);
        }
        return deleteModalInstance;
    }
    
    // Función para mostrar alerta personalizada
    function showAlert(message, title = 'Información', type = 'info') {
        const modal = getAlertModal();
        const iconElement = document.getElementById('customAlertIcon');
        const titleElement = document.getElementById('customAlertTitleText');
        const messageElement = document.getElementById('customAlertMessage');
        
        // Configurar icono y color según el tipo
        const types = {
            'info': { icon: 'fa-info-circle', color: 'text-info' },
            'warning': { icon: 'fa-exclamation-triangle', color: 'text-warning' },
            'success': { icon: 'fa-check-circle', color: 'text-success' },
            'error': { icon: 'fa-times-circle', color: 'text-danger' }
        };
        
        const config = types[type] || types['info'];
        iconElement.className = `fas ${config.icon} me-2 ${config.color}`;
        titleElement.textContent = title;
        messageElement.textContent = message;
        
        modal.show();
    }
    
    // Función para mostrar confirmación personalizada
    function showConfirm(message, onConfirm, title = '¿Estás seguro?') {
        // Si el título contiene "eliminación" o "eliminar", usar el modal de eliminación
        if (title.toLowerCase().includes('eliminación') || title.toLowerCase().includes('eliminar')) {
            return showDeleteConfirm(message, onConfirm, title);
        }
        
        return new Promise((resolve) => {
            const modal = getConfirmModal();
            const titleElement = document.getElementById('customConfirmTitle');
            const messageElement = document.getElementById('customConfirmMessage');
            const confirmBtn = document.getElementById('customConfirmBtn');
            
            titleElement.textContent = title;
            messageElement.textContent = message;
            
            // Limpiar listeners anteriores
            const newConfirmBtn = confirmBtn.cloneNode(true);
            confirmBtn.parentNode.replaceChild(newConfirmBtn, confirmBtn);
            
            // Agregar nuevo listener
            document.getElementById('customConfirmBtn').addEventListener('click', function() {
                modal.hide();
                if (typeof onConfirm === 'function') {
                    onConfirm();
                }
                resolve(true);
            });
            
            // Resolver false si se cancela
            document.getElementById('customConfirmModal').addEventListener('hidden.bs.modal', function onHide() {
                resolve(false);
                this.removeEventListener('hidden.bs.modal', onHide);
            }, { once: true });
            
            modal.show();
        });
    }
    
    // Función para mostrar confirmación de eliminación con diseño destructivo
    function showDeleteConfirm(message, onConfirm, title = 'Confirmar eliminación') {
        return new Promise((resolve) => {
            const modal = getDeleteModal();
            const messageElement = document.getElementById('customDeleteMessage');
            const deleteBtn = document.getElementById('customDeleteBtn');
            
            messageElement.innerHTML = message || '¿Estás seguro de que deseas eliminar este elemento?';
            
            // Limpiar listeners anteriores
            const newDeleteBtn = deleteBtn.cloneNode(true);
            deleteBtn.parentNode.replaceChild(newDeleteBtn, deleteBtn);
            
            // Agregar nuevo listener
            document.getElementById('customDeleteBtn').addEventListener('click', function() {
                modal.hide();
                if (typeof onConfirm === 'function') {
                    onConfirm();
                }
                resolve(true);
            });
            
            // Resolver false si se cancela
            document.getElementById('customDeleteModal').addEventListener('hidden.bs.modal', function onHide() {
                resolve(false);
                this.removeEventListener('hidden.bs.modal', onHide);
            }, { once: true });
            
            modal.show();
        });
    }
    
    // Función para mostrar éxito
    function showSuccess(message) {
        const modal = getSuccessModal();
        document.getElementById('customSuccessMessage').textContent = message;
        modal.show();
    }
    
    // Función para mostrar error
    function showError(message) {
        const modal = getErrorModal();
        document.getElementById('customErrorMessage').textContent = message;
        modal.show();
    }
    
    // Reemplazar alert y confirm nativos (opcional)
    // window.alert = showAlert;
    // window.confirm = (msg) => showConfirm(msg, () => {});
</script>

