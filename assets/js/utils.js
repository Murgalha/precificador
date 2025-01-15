function openModal(title, content, action) {
  const modal = document.getElementById('modal');

  if (modal) {
    const modalTitle = modal.querySelector('.modal-title');
    const modalBody = modal.querySelector('.modal-body');
    const modalActionButton = modal.querySelector('#modal-action-button');

    modalTitle.textContent = title;
    modalBody.textContent = content;
    modalActionButton.onclick = async () => {
      await action();
      location.reload();
    };
  }
}
