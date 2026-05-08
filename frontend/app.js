const users = [
  { id: 1, name: "Aarav Sharma", email: "aarav.sharma@example.com" },
  { id: 2, name: "Ananya Iyer", email: "ananya.iyer@example.com" },
  { id: 3, name: "Rohan Verma", email: "rohan.verma@example.com" },
  { id: 4, name: "Priya Nair", email: "priya.nair@example.com" },
  { id: 5, name: "Karan Mehta", email: "karan.mehta@example.com" },
  { id: 6, name: "Sneha Kulkarni", email: "sneha.kulkarni@example.com" },
  { id: 7, name: "Aditya Rao", email: "aditya.rao@example.com" },
  { id: 8, name: "Meera Menon", email: "meera.menon@example.com" },
  { id: 9, name: "Vikram Singh", email: "vikram.singh@example.com" },
  { id: 10, name: "Isha Gupta", email: "isha.gupta@example.com" },
  { id: 11, name: "Arjun Reddy", email: "arjun.reddy@example.com" },
  { id: 12, name: "Neha Joshi", email: "neha.joshi@example.com" },
  { id: 13, name: "Siddharth Jain", email: "siddharth.jain@example.com" },
  { id: 14, name: "Pooja Patel", email: "pooja.patel@example.com" },
  { id: 15, name: "Rahul Das", email: "rahul.das@example.com" },
  { id: 16, name: "Kavya Pillai", email: "kavya.pillai@example.com" },
  { id: 17, name: "Nikhil Bansal", email: "nikhil.bansal@example.com" },
  { id: 18, name: "Aditi Chatterjee", email: "aditi.chatterjee@example.com" },
  { id: 19, name: "Manish Malhotra", email: "manish.malhotra@example.com" },
  { id: 20, name: "Divya Krishnan", email: "divya.krishnan@example.com" },
  { id: 21, name: "Harsh Agarwal", email: "harsh.agarwal@example.com" },
  { id: 22, name: "Tanvi Saxena", email: "tanvi.saxena@example.com" },
  { id: 23, name: "Yash Kapoor", email: "yash.kapoor@example.com" },
  { id: 24, name: "Ritika Sinha", email: "ritika.sinha@example.com" },
  { id: 25, name: "Mohit Khanna", email: "mohit.khanna@example.com" },
  { id: 26, name: "Shreya Ghosh", email: "shreya.ghosh@example.com" },
  { id: 27, name: "Saurabh Mishra", email: "saurabh.mishra@example.com" },
  { id: 28, name: "Naina Bhatia", email: "naina.bhatia@example.com" },
  { id: 29, name: "Devansh Shah", email: "devansh.shah@example.com" },
  { id: 30, name: "Simran Kaur", email: "simran.kaur@example.com" }
];

const departments = [
  { id: 1, name: "Maintenance" },
  { id: 2, name: "IT" },
  { id: 3, name: "Housekeeping" },
  { id: 4, name: "Security" },
  { id: 5, name: "Mess/Cafeteria" },
  { id: 6, name: "Administration" },
  { id: 7, name: "Electrical" },
  { id: 8, name: "Plumbing" }
];

const categories = [
  { id: 1, name: "Noise" },
  { id: 2, name: "Water Leakage" },
  { id: 3, name: "Power Outage" },
  { id: 4, name: "Internet Issue" },
  { id: 5, name: "Cleanliness" },
  { id: 6, name: "Pest Control" },
  { id: 7, name: "Furniture Damage" },
  { id: 8, name: "Food Quality" },
  { id: 9, name: "Security Breach" },
  { id: 10, name: "Other" }
];

const staffByDepartment = {
  1: "Ramesh Yadav",
  2: "Kunal Bedi",
  3: "Lata More",
  4: "Prakash Rawat",
  5: "Joseph Dsouza",
  6: "Mahesh Pillai",
  7: "Vivek Pandey",
  8: "Bharat Lal"
};

let complaints = [
  { id: 1, userId: 1, categoryId: 4, departmentId: 2, description: "Wi-Fi disconnecting repeatedly in hostel block A.", status: "Resolved", priority: "High", registered: "2024-01-05", resolved: "2024-01-08" },
  { id: 2, userId: 2, categoryId: 2, departmentId: 8, description: "Water leakage near washroom pipeline on second floor.", status: "Resolved", priority: "Medium", registered: "2024-01-18", resolved: "2024-01-24" },
  { id: 3, userId: 3, categoryId: 3, departmentId: 7, description: "Power outage in computer lab during evening hours.", status: "In Progress", priority: "High", registered: "2024-02-02", resolved: null },
  { id: 4, userId: 4, categoryId: 5, departmentId: 3, description: "Corridor cleaning not completed for three days.", status: "Resolved", priority: "Low", registered: "2024-02-12", resolved: "2024-02-13" },
  { id: 5, userId: 5, categoryId: 8, departmentId: 5, description: "Dinner quality was poor and food was served cold.", status: "Pending", priority: "Medium", registered: "2024-02-25", resolved: null },
  { id: 6, userId: 6, categoryId: 9, departmentId: 4, description: "Unknown person entered hostel without ID check.", status: "In Progress", priority: "High", registered: "2024-03-03", resolved: null },
  { id: 7, userId: 7, categoryId: 7, departmentId: 1, description: "Study table leg broken in room B-214.", status: "Resolved", priority: "Low", registered: "2024-03-15", resolved: "2024-03-18" },
  { id: 8, userId: 8, categoryId: 1, departmentId: 6, description: "Loud construction noise during examination week.", status: "Resolved", priority: "Medium", registered: "2024-03-28", resolved: "2024-04-03" },
  { id: 9, userId: 9, categoryId: 6, departmentId: 3, description: "Cockroaches found in common pantry area.", status: "Pending", priority: "High", registered: "2024-04-07", resolved: null },
  { id: 10, userId: 10, categoryId: 10, departmentId: 6, description: "Request for updated notice board information.", status: "Resolved", priority: "Low", registered: "2024-04-20", resolved: "2024-04-22" },
  { id: 11, userId: 11, categoryId: 4, departmentId: 2, description: "LAN port not working in room C-109.", status: "Resolved", priority: "Medium", registered: "2024-05-04", resolved: "2024-05-10" },
  { id: 12, userId: 12, categoryId: 3, departmentId: 7, description: "Frequent voltage fluctuation in seminar hall.", status: "Resolved", priority: "High", registered: "2024-05-17", resolved: "2024-06-01" },
  { id: 13, userId: 13, categoryId: 2, departmentId: 8, description: "Tap continuously running in ground floor washroom.", status: "In Progress", priority: "Medium", registered: "2024-06-02", resolved: null },
  { id: 14, userId: 14, categoryId: 5, departmentId: 3, description: "Overflowing dustbins near hostel entrance.", status: "Resolved", priority: "Low", registered: "2024-06-16", resolved: "2024-06-17" },
  { id: 15, userId: 15, categoryId: 8, departmentId: 5, description: "Breakfast items not available by serving time.", status: "Pending", priority: "Medium", registered: "2024-06-30", resolved: null },
  { id: 16, userId: 16, categoryId: 9, departmentId: 4, description: "CCTV camera near gate three is not recording.", status: "Resolved", priority: "High", registered: "2024-07-08", resolved: "2024-07-20" },
  { id: 17, userId: 17, categoryId: 7, departmentId: 1, description: "Chair in reading room has damaged back support.", status: "Resolved", priority: "Low", registered: "2024-07-19", resolved: "2024-07-21" },
  { id: 18, userId: 18, categoryId: 4, departmentId: 2, description: "Email portal password reset link not received.", status: "In Progress", priority: "Medium", registered: "2024-08-01", resolved: null },
  { id: 19, userId: 19, categoryId: 3, departmentId: 7, description: "Tube light flickering in room A-310.", status: "Pending", priority: "Low", registered: "2024-08-14", resolved: null },
  { id: 20, userId: 20, categoryId: 2, departmentId: 8, description: "Drain blocked near hostel courtyard.", status: "Resolved", priority: "High", registered: "2024-08-29", resolved: "2024-09-04" },
  { id: 21, userId: 21, categoryId: 1, departmentId: 6, description: "Auditorium event noise continued beyond permitted time.", status: "Resolved", priority: "Medium", registered: "2024-09-10", resolved: "2024-09-14" },
  { id: 22, userId: 22, categoryId: 6, departmentId: 3, description: "Mosquito breeding near stagnant water area.", status: "In Progress", priority: "High", registered: "2024-09-21", resolved: null },
  { id: 23, userId: 23, categoryId: 10, departmentId: 1, description: "Window latch requires repair in lab corridor.", status: "Resolved", priority: "Low", registered: "2024-10-05", resolved: "2024-10-09" },
  { id: 24, userId: 24, categoryId: 4, departmentId: 2, description: "Online attendance portal inaccessible from campus network.", status: "Pending", priority: "High", registered: "2024-10-18", resolved: null },
  { id: 25, userId: 25, categoryId: 8, departmentId: 5, description: "Mess menu not followed for two consecutive days.", status: "Resolved", priority: "Medium", registered: "2024-11-01", resolved: "2024-11-06" },
  { id: 26, userId: 26, categoryId: 5, departmentId: 3, description: "Washroom mirror and floor not cleaned properly.", status: "Resolved", priority: "Low", registered: "2024-11-12", resolved: "2024-11-13" },
  { id: 27, userId: 27, categoryId: 3, departmentId: 7, description: "Main corridor lights off after 8 PM.", status: "In Progress", priority: "High", registered: "2024-11-24", resolved: null },
  { id: 28, userId: 28, categoryId: 9, departmentId: 4, description: "Visitor register was unattended at front gate.", status: "Pending", priority: "High", registered: "2024-12-04", resolved: null },
  { id: 29, userId: 29, categoryId: 2, departmentId: 8, description: "Low water pressure in third floor washroom.", status: "Resolved", priority: "Medium", registered: "2024-12-15", resolved: "2024-12-28" },
  { id: 30, userId: 30, categoryId: 7, departmentId: 1, description: "Cupboard handle broken in room D-102.", status: "Resolved", priority: "Low", registered: "2024-12-26", resolved: "2024-12-30" },
  { id: 31, userId: 1, categoryId: 4, departmentId: 2, description: "Campus LMS timing out during assignment upload.", status: "Pending", priority: "High", registered: "2025-01-07", resolved: null },
  { id: 32, userId: 2, categoryId: 8, departmentId: 5, description: "Lunch rice was undercooked on multiple days.", status: "Resolved", priority: "Medium", registered: "2025-01-16", resolved: "2025-01-22" },
  { id: 33, userId: 3, categoryId: 5, departmentId: 3, description: "Staircase area has not been swept after renovation work.", status: "In Progress", priority: "Low", registered: "2025-01-30", resolved: null },
  { id: 34, userId: 4, categoryId: 3, departmentId: 7, description: "Backup generator did not start during power cut.", status: "Resolved", priority: "High", registered: "2025-02-11", resolved: "2025-02-25" },
  { id: 35, userId: 5, categoryId: 2, departmentId: 8, description: "Seepage visible on ceiling near room B-305.", status: "Pending", priority: "High", registered: "2025-02-20", resolved: null },
  { id: 36, userId: 6, categoryId: 9, departmentId: 4, description: "Hostel gate entry scanner not working.", status: "Resolved", priority: "High", registered: "2025-03-03", resolved: "2025-03-14" },
  { id: 37, userId: 7, categoryId: 1, departmentId: 6, description: "Late night loudspeaker use near admin lawn.", status: "Resolved", priority: "Medium", registered: "2025-03-12", resolved: "2025-03-15" },
  { id: 38, userId: 8, categoryId: 6, departmentId: 3, description: "Termite marks found near wooden cupboard.", status: "In Progress", priority: "Medium", registered: "2025-03-24", resolved: null },
  { id: 39, userId: 9, categoryId: 4, departmentId: 2, description: "Computer lab printer not reachable over network.", status: "Resolved", priority: "Low", registered: "2025-04-02", resolved: "2025-04-05" },
  { id: 40, userId: 10, categoryId: 3, departmentId: 7, description: "Electrical socket sparking in room C-204.", status: "Pending", priority: "High", registered: "2025-04-12", resolved: null },
  { id: 41, userId: 11, categoryId: 10, departmentId: 6, description: "Duplicate fee receipt required from office.", status: "Resolved", priority: "Low", registered: "2025-04-19", resolved: "2025-04-21" },
  { id: 42, userId: 12, categoryId: 2, departmentId: 8, description: "Water cooler outlet leaking continuously.", status: "Resolved", priority: "Medium", registered: "2025-04-28", resolved: "2025-05-03" },
  { id: 43, userId: 13, categoryId: 8, departmentId: 5, description: "Tea served was stale in evening snack counter.", status: "In Progress", priority: "Low", registered: "2025-05-05", resolved: null },
  { id: 44, userId: 14, categoryId: 7, departmentId: 1, description: "Bench in classroom F-12 is unstable.", status: "Pending", priority: "Medium", registered: "2025-05-14", resolved: null },
  { id: 45, userId: 15, categoryId: 5, departmentId: 3, description: "Garbage collection skipped behind hostel block.", status: "Resolved", priority: "Medium", registered: "2025-05-21", resolved: "2025-05-24" },
  { id: 46, userId: 16, categoryId: 4, departmentId: 2, description: "Biometric attendance device offline.", status: "Resolved", priority: "High", registered: "2025-05-27", resolved: "2025-06-05" },
  { id: 47, userId: 17, categoryId: 3, departmentId: 7, description: "Ceiling fan stopped working in room B-101.", status: "In Progress", priority: "Medium", registered: "2025-06-04", resolved: null },
  { id: 48, userId: 18, categoryId: 9, departmentId: 4, description: "Emergency exit was blocked by parked vehicles.", status: "Pending", priority: "High", registered: "2025-06-11", resolved: null },
  { id: 49, userId: 19, categoryId: 6, departmentId: 3, description: "Ant infestation reported in mess storage area.", status: "Resolved", priority: "High", registered: "2025-06-20", resolved: "2025-06-29" },
  { id: 50, userId: 20, categoryId: 2, departmentId: 8, description: "Bathroom flush tank not filling correctly.", status: "Pending", priority: "Medium", registered: "2025-06-30", resolved: null }
];

const state = { view: "dashboard", search: "", status: "All", priority: "All", department: "All" };

const byId = (items, id) => items.find((item) => item.id === id);
const formatDate = (value) => value ? new Date(`${value}T00:00:00`).toLocaleDateString("en-IN", { day: "2-digit", month: "short", year: "numeric" }) : "Not resolved";
const statusClass = (status) => `status-${status.toLowerCase().replaceAll(" ", "-")}`;
const priorityClass = (priority) => `priority-${priority.toLowerCase()}`;

function complaintViewModel(complaint) {
  const user = byId(users, complaint.userId);
  const department = byId(departments, complaint.departmentId);
  const category = byId(categories, complaint.categoryId);
  return {
    ...complaint,
    userName: user?.name || "Unknown user",
    userEmail: user?.email || "No email available",
    departmentName: department?.name || "Unknown department",
    categoryName: category?.name || "Other",
    staffName: staffByDepartment[complaint.departmentId] || "Unassigned"
  };
}

function filteredComplaints() {
  const term = state.search.trim().toLowerCase();
  return complaints
    .map(complaintViewModel)
    .filter((item) => state.status === "All" || item.status === state.status)
    .filter((item) => state.priority === "All" || item.priority === state.priority)
    .filter((item) => state.department === "All" || item.departmentName === state.department)
    .filter((item) => {
      if (!term) return true;
      return [item.id, item.userName, item.departmentName, item.categoryName, item.description, item.status, item.priority].join(" ").toLowerCase().includes(term);
    })
    .sort((a, b) => new Date(b.registered) - new Date(a.registered));
}

function countBy(items, key) {
  return items.reduce((counts, item) => {
    counts[item[key]] = (counts[item[key]] || 0) + 1;
    return counts;
  }, {});
}

function renderMetrics() {
  const resolved = complaints.filter((item) => item.status === "Resolved").length;
  const high = complaints.filter((item) => item.priority === "High" && item.status !== "Resolved").length;
  const open = complaints.length - resolved;
  const resolutionRate = Math.round((resolved / complaints.length) * 100);
  const metrics = [
    ["Total complaints", complaints.length, "Records from SQL seed"],
    ["Open complaints", open, "Pending and in progress"],
    ["High priority open", high, "Needs quicker attention"],
    ["Resolution rate", `${resolutionRate}%`, "Resolved out of total"]
  ];

  document.querySelector("#metric-grid").innerHTML = metrics.map(([label, value, hint]) => `
    <article class="metric">
      <span>${label}</span>
      <strong>${value}</strong>
      <span>${hint}</span>
    </article>
  `).join("");
}

function renderStatusBars() {
  const counts = countBy(complaints, "status");
  document.querySelector("#status-total").textContent = `${complaints.length} complaints`;
  document.querySelector("#status-bars").innerHTML = ["Pending", "In Progress", "Resolved"].map((status) => {
    const count = counts[status] || 0;
    const width = Math.round((count / complaints.length) * 100);
    return `
      <div class="bar-row">
        <strong>${status}</strong>
        <div class="bar-track"><div class="bar-fill ${statusClass(status).replace("status-", "")}" style="width:${width}%"></div></div>
        <span>${count}</span>
      </div>
    `;
  }).join("");
}

function renderPriorityStack() {
  const counts = countBy(complaints, "priority");
  document.querySelector("#priority-stack").innerHTML = ["High", "Medium", "Low"].map((priority) => {
    const count = counts[priority] || 0;
    const width = Math.max(12, Math.round((count / complaints.length) * 100));
    return `<div class="priority-segment ${priorityClass(priority)}" style="width:${width}%">${priority}<br>${count} (${width}%)</div>`;
  }).join("");
}

function rowTemplate(item, compact = false) {
  if (compact) {
    return `
      <tr>
        <td>#${item.id}</td>
        <td>${item.userName}</td>
        <td>${item.departmentName}</td>
        <td><span class="pill ${priorityClass(item.priority)}">${item.priority}</span></td>
        <td><span class="pill ${statusClass(item.status)}">${item.status}</span></td>
        <td>${formatDate(item.registered)}</td>
      </tr>
    `;
  }

  return `
    <tr>
      <td>#${item.id}</td>
      <td>${item.userName}</td>
      <td>${item.categoryName}</td>
      <td>${item.departmentName}</td>
      <td><span class="pill ${priorityClass(item.priority)}">${item.priority}</span></td>
      <td><span class="pill ${statusClass(item.status)}">${item.status}</span></td>
      <td>${formatDate(item.registered)}</td>
      <td><button class="ghost-action" data-detail="${item.id}">Open</button></td>
    </tr>
  `;
}

function renderTables() {
  const rows = filteredComplaints();
  document.querySelector("#recent-rows").innerHTML = complaints.map(complaintViewModel).sort((a, b) => new Date(b.registered) - new Date(a.registered)).slice(0, 6).map((item) => rowTemplate(item, true)).join("");
  document.querySelector("#complaint-rows").innerHTML = rows.map((item) => rowTemplate(item)).join("");
  document.querySelector("#complaint-count").textContent = `${rows.length} of ${complaints.length} shown`;
}

function renderDepartments() {
  const departmentStats = departments.map((department) => {
    const records = complaints.filter((item) => item.departmentId === department.id);
    const resolved = records.filter((item) => item.status === "Resolved").length;
    const open = records.length - resolved;
    const rate = records.length ? Math.round((resolved / records.length) * 100) : 0;
    return { ...department, total: records.length, resolved, open, rate };
  }).sort((a, b) => b.total - a.total);

  document.querySelector("#department-list").innerHTML = departmentStats.map((item) => `
    <div class="department-row">
      <div>
        <strong>${item.name}</strong>
        <small>${item.total} total complaints</small>
      </div>
      <div class="bar-track"><div class="bar-fill resolved" style="width:${item.rate}%"></div></div>
      <span>${item.resolved} resolved</span>
      <span>${item.open} open</span>
    </div>
  `).join("");
}

function populateSelects() {
  const departmentOptions = departments.map((department) => `<option>${department.name}</option>`).join("");
  document.querySelector("#department-filter").insertAdjacentHTML("beforeend", departmentOptions);
  document.querySelector("#department-field").innerHTML = departments.map((department) => `<option value="${department.id}">${department.name}</option>`).join("");
  document.querySelector("#category-field").innerHTML = categories.map((category) => `<option value="${category.id}">${category.name}</option>`).join("");
  document.querySelector("#user-field").innerHTML = users.map((user) => `<option value="${user.id}">${user.name}</option>`).join("");
}

function switchView(view) {
  state.view = view;
  document.querySelectorAll(".view").forEach((section) => section.classList.toggle("active", section.id === `${view}-view`));
  document.querySelectorAll(".nav-tab").forEach((button) => button.classList.toggle("active", button.dataset.view === view));
  const titles = { dashboard: "Dashboard", complaints: "Complaints", departments: "Departments", new: "Register Complaint" };
  document.querySelector("#page-title").textContent = titles[view];
}

function openDetail(id) {
  const item = complaintViewModel(complaints.find((complaint) => complaint.id === id));
  document.querySelector("#detail-title").textContent = `Complaint #${item.id}`;
  document.querySelector("#detail-body").innerHTML = `
    <p>${item.description}</p>
    <div class="detail-grid">
      <div class="detail-item"><span>Complainant</span><strong>${item.userName}</strong><br>${item.userEmail}</div>
      <div class="detail-item"><span>Department</span><strong>${item.departmentName}</strong></div>
      <div class="detail-item"><span>Category</span><strong>${item.categoryName}</strong></div>
      <div class="detail-item"><span>Assigned staff</span><strong>${item.staffName}</strong></div>
      <div class="detail-item"><span>Priority</span><strong>${item.priority}</strong></div>
      <div class="detail-item"><span>Status</span><strong>${item.status}</strong></div>
      <div class="detail-item"><span>Registered</span><strong>${formatDate(item.registered)}</strong></div>
      <div class="detail-item"><span>Resolved</span><strong>${formatDate(item.resolved)}</strong></div>
    </div>
  `;
  document.querySelector("#detail-dialog").showModal();
}

function bindEvents() {
  document.querySelectorAll("[data-view], [data-view-target]").forEach((button) => {
    button.addEventListener("click", () => switchView(button.dataset.view || button.dataset.viewTarget));
  });

  document.querySelector("#search-input").addEventListener("input", (event) => {
    state.search = event.target.value;
    renderTables();
  });

  document.querySelector("#status-filter").addEventListener("change", (event) => {
    state.status = event.target.value;
    renderTables();
  });

  document.querySelector("#priority-filter").addEventListener("change", (event) => {
    state.priority = event.target.value;
    renderTables();
  });

  document.querySelector("#department-filter").addEventListener("change", (event) => {
    state.department = event.target.value;
    renderTables();
  });

  document.querySelector("#complaint-rows").addEventListener("click", (event) => {
    const button = event.target.closest("[data-detail]");
    if (button) openDetail(Number(button.dataset.detail));
  });

  document.querySelector("#close-dialog").addEventListener("click", () => {
    document.querySelector("#detail-dialog").close();
  });

  document.querySelector("#complaint-form").addEventListener("submit", (event) => {
    event.preventDefault();
    const nextId = Math.max(...complaints.map((complaint) => complaint.id)) + 1;
    complaints = [{
      id: nextId,
      userId: Number(document.querySelector("#user-field").value),
      categoryId: Number(document.querySelector("#category-field").value),
      departmentId: Number(document.querySelector("#department-field").value),
      description: document.querySelector("#description-field").value.trim(),
      status: "Pending",
      priority: document.querySelector("#priority-field").value,
      registered: new Date().toISOString().slice(0, 10),
      resolved: null
    }, ...complaints];
    event.target.reset();
    renderAll();
    switchView("complaints");
  });
}

function renderAll() {
  renderMetrics();
  renderStatusBars();
  renderPriorityStack();
  renderTables();
  renderDepartments();
}

populateSelects();
bindEvents();
renderAll();
