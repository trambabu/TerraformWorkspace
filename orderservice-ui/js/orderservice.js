// replace the below with your actual endpoint 
//const API_BASE = "http://localhost:8080/orders"; 

const API_BASE = CONFIG.API_BASE;

// rest of the code remains same

// Load all orders
function loadOrders() {
    axios.get(API_BASE)
        .then(res => {
            const tbody = document.querySelector("#ordersTable tbody");
            tbody.innerHTML = "";
            res.data.forEach(order => {
                tbody.innerHTML += `<tr>
                    <td>${order.id}</td>
                    <td>${order.customerName}</td>
                    <td>${order.product}</td>
                    <td>${order.quantity}</td>
                    <td>
                        <a href="view-order.html?id=${order.id}" class="btn btn-info btn-sm">View</a>
                        <a href="update-order.html?id=${order.id}" class="btn btn-warning btn-sm">Edit</a>
                        <button onclick="deleteOrder(${order.id})" class="btn btn-danger btn-sm">Delete</button>
                    </td>
                </tr>`;
            });
        });
}

// Create new order
function createOrder() {
    const order = {
        customerName: document.getElementById("customerName").value,
        product: document.getElementById("product").value,
        quantity: document.getElementById("quantity").value
    };
    axios.post(API_BASE, order)
        .then(() => window.location.href = "index.html")
        .catch(err => alert(err));
}

// Load single order for update
function loadOrder(id) {
    axios.get(`${API_BASE}/${id}`)
        .then(res => {
            const order = res.data;
            document.getElementById("orderId").value = order.id;
            document.getElementById("customerName").value = order.customerName;
            document.getElementById("product").value = order.product;
            document.getElementById("quantity").value = order.quantity;
        });
}

// Update order
function updateOrder() {
    const id = document.getElementById("orderId").value;
    const order = {
        customerName: document.getElementById("customerName").value,
        product: document.getElementById("product").value,
        quantity: document.getElementById("quantity").value
    };
    axios.put(`${API_BASE}/${id}`, order)
        .then(() => window.location.href = "index.html")
        .catch(err => alert(err));
}

// Delete order
function deleteOrder(id) {
    if(confirm("Are you sure to delete this order?")) {
        axios.delete(`${API_BASE}/${id}`)
            .then(() => loadOrders())
            .catch(err => alert(err));
    }
}

// View order
function viewOrder(id) {
    axios.get(`${API_BASE}/${id}`)
        .then(res => {
            const order = res.data;
            const ul = document.getElementById("orderDetails");
            ul.innerHTML = `
                <li class="list-group-item"><strong>ID:</strong> ${order.id}</li>
                <li class="list-group-item"><strong>Customer Name:</strong> ${order.customerName}</li>
                <li class="list-group-item"><strong>Product:</strong> ${order.product}</li>
                <li class="list-group-item"><strong>Quantity:</strong> ${order.quantity}</li>
            `;
        });
}
