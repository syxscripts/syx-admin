(() => {
  const app = document.getElementById('app');
  const adminCountEl = document.getElementById('adminCount');
  const adminListEl = document.getElementById('adminList');
  const playerListEl = document.getElementById('playerList');
  const playerSearchEl = document.getElementById('playerSearch');

  let state = {
    admins: [],
    onlinePlayers: [],
    canManage: false,
    query: '',
  };

  function initials(name) {
    return (name || '?').trim().split(/\s+/).slice(0, 2).map(w => w[0]).join('').toUpperCase();
  }

  function renderAdmins() {
    adminCountEl.textContent = `${state.admins.length} ADMIN${state.admins.length === 1 ? '' : 'S'}`;

    if (!state.admins.length) {
      adminListEl.innerHTML = `<div class="empty-state">No admins yet.</div>`;
      return;
    }

    adminListEl.innerHTML = state.admins.map(a => `
      <div class="admin-row" data-license="${a.license}">
        <div class="admin-avatar">${initials(a.name)}</div>
        <div class="admin-info">
          <div class="admin-name">${a.name}${a.super ? '<span class="super-badge">SUPER</span>' : ''}</div>
          <div class="admin-sub">${a.super ? 'Set in config.lua' : `Added by ${a.addedBy}`}</div>
        </div>
        ${(!a.super && state.canManage) ? `
          <button class="remove-btn" data-remove="${a.license}" title="Remove admin">
            <svg viewBox="0 0 24 24"><path d="M4 7h16M9 7V4h6v3m-8 0 1 13h8l1-13"/></svg>
          </button>` : ''}
      </div>
    `).join('');

    adminListEl.querySelectorAll('[data-remove]').forEach(btn => {
      btn.addEventListener('click', () => {
        SyxUI.post('removeAdmin', { license: btn.dataset.remove });
      });
    });
  }

  function renderPlayers() {
    let list = state.onlinePlayers;
    if (state.query.trim()) {
      const q = state.query.trim().toLowerCase();
      list = list.filter(p => p.name.toLowerCase().includes(q) || String(p.id).includes(q));
    }

    if (!list.length) {
      playerListEl.innerHTML = `<div class="empty-state">No matching online players.</div>`;
      return;
    }

    playerListEl.innerHTML = list.map(p => `
      <div class="player-row">
        <span class="player-id">#${p.id}</span>
        <span class="player-name">${p.name}</span>
        <button class="add-btn" data-add="${p.id}" ${state.canManage ? '' : 'disabled'}>ADD</button>
      </div>
    `).join('');

    playerListEl.querySelectorAll('[data-add]').forEach(btn => {
      btn.addEventListener('click', () => {
        SyxUI.post('addAdmin', { id: btn.dataset.add });
        btn.textContent = 'ADDED';
        btn.disabled = true;
      });
    });
  }

  // ---------------- tabs ----------------
  document.querySelectorAll('#mainTabs .tab-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      document.querySelectorAll('#mainTabs .tab-chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      const tab = chip.dataset.tab;
      document.getElementById('view-admins').style.display = tab === 'admins' ? 'flex' : 'none';
      document.getElementById('view-add').style.display = tab === 'add' ? 'flex' : 'none';
    });
  });

  playerSearchEl.addEventListener('input', e => {
    state.query = e.target.value;
    renderPlayers();
  });

  document.getElementById('refreshBtn').addEventListener('click', () => {
    SyxUI.post('refresh');
  });

  function closeApp() {
    app.classList.remove('visible');
    app.classList.add('hidden');
  }

  document.getElementById('closeBtn').addEventListener('click', () => {
    SyxUI.post('closeMenu');
    closeApp();
  });

  document.addEventListener('keydown', e => {
    if (!app.classList.contains('visible')) return;
    if (e.key === 'Escape') {
      e.preventDefault();
      SyxUI.post('closeMenu');
      closeApp();
    }
  });

  window.addEventListener('message', e => {
    const data = e.data || {};

    if (data.action === 'open') {
      state.admins = data.admins || [];
      state.onlinePlayers = data.onlinePlayers || [];
      state.canManage = !!data.canManage;
      state.query = '';
      playerSearchEl.value = '';

      renderAdmins();
      renderPlayers();

      app.classList.remove('hidden');
      requestAnimationFrame(() => app.classList.add('visible'));

    } else if (data.action === 'close') {
      closeApp();

    } else if (data.action === 'toast') {
      SyxUI.toast(data.message, data.kind);
    }
  });
})();
