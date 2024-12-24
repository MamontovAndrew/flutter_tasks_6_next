package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

var (
	db         *sql.DB
	supabaseKey string
	jwksURL    string
	expectedAud = ""
)

func enableCorsMiddleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Access-Control-Allow-Origin", "*")
        w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
        w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

        if r.Method == "OPTIONS" {
            w.WriteHeader(http.StatusOK)
            return
        }
        next.ServeHTTP(w, r)
    })
}

func enableCors(w *http.ResponseWriter) {
	(*w).Header().Set("Access-Control-Allow-Origin", "*")
	(*w).Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	(*w).Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
}

type Product struct {
	ProductID   int     `json:"product_id"`
	ImageURL    string  `json:"image_url"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Price       float64 `json:"price"`
	Stock       int     `json:"stock"`
	CreatedAt   string  `json:"created_at"`
}

// Точка входа
func main() {
	if err := godotenv.Load("../.env"); err != nil {
		fmt.Println("Error loading .env file")
		os.Exit(1)
	}

	connStr := "postgres://postgres:123123@localhost:5432/shop?sslmode=disable"
	var err error
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		fmt.Println("Error connecting to the database:", err)
		os.Exit(1)
	}
	defer db.Close()

	err = db.Ping()
	if err != nil {
		fmt.Println("Error pinging the database:", err)
		os.Exit(1)
	}

	http.HandleFunc("/test", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("Received request at /test")
		w.Write([]byte("Test endpoint is working"))
	})

	// products
	http.Handle("/products", enableCorsMiddleware(http.HandlerFunc(productsHandler)))
	http.Handle("/products/", enableCorsMiddleware(http.HandlerFunc(productsHandler)))

	// favorites
	http.Handle("/favorites", enableCorsMiddleware(http.HandlerFunc(favoritesHandler)))
	http.Handle("/favorites/remove/", enableCorsMiddleware(http.HandlerFunc(favoritesHandler)))

	// cart
	http.Handle("/cart", enableCorsMiddleware(http.HandlerFunc(cartHandler)))
	http.Handle("/cart/update/", enableCorsMiddleware(http.HandlerFunc(cartHandler)))
	http.Handle("/cart/remove/", enableCorsMiddleware(http.HandlerFunc(cartHandler)))

	// profile
	http.Handle("/users/profile", enableCorsMiddleware(http.HandlerFunc(userProfileHandler)))
	http.Handle("/users", enableCorsMiddleware(http.HandlerFunc(createUserHandler)))
	http.Handle("/users/profile/update", enableCorsMiddleware(http.HandlerFunc(updateUserProfileHandler)))

	// orders
    http.HandleFunc("/orders", func(w http.ResponseWriter, r *http.Request) {
    		fmt.Println("Обработчик /orders вызван для пути:", r.URL.Path)

    		if strings.HasSuffix(r.URL.Path, "/items") {
    			getOrderItemsHandler(w, r)
    			return
    		}

    		if r.URL.Path == "/orders" && r.Method == http.MethodGet {
    			getOrdersHandler(w, r)
    			return
    		}

    		if r.URL.Path == "/orders" && r.Method == http.MethodPost {
    			createOrderHandler(w, r)
    			return
    		}

    		http.Error(w, "Not Found", http.StatusNotFound)
    	})

	http.HandleFunc("/orders/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("Обработчик /orders/ вызван для пути:", r.URL.Path)

		if strings.HasSuffix(r.URL.Path, "/items") {
			getOrderItemsHandler(w, r)
			return
		}

		if r.URL.Path == "/orders/" && r.Method == http.MethodGet {
			getOrdersHandler(w, r)
			return
		}

		if r.URL.Path == "/orders/" && r.Method == http.MethodPost {
			createOrderHandler(w, r)
			return
		}

		http.Error(w, "Not Found", http.StatusNotFound)
	})

	fmt.Println("Server is running on port 8080!")
	http.ListenAndServe(":8080", nil)
}

// ---------------- PRODUCTS ------------------

func productsHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	switch {
	case r.URL.Path == "/products" && r.Method == http.MethodGet:
		getProductsHandler(w, r)
	case r.URL.Path == "/products" && r.Method == http.MethodPost:
		createProductHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/products/update/") && r.Method == http.MethodPut:
		updateProductHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/products/delete/") && r.Method == http.MethodDelete:
		deleteProductHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/products/") && r.Method == http.MethodGet:
		getProductByIDHandler(w, r)
	default:
		http.Error(w, "Not Found", http.StatusNotFound)
	}
}

func getProductsHandler(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query("SELECT product_id, image_url, name, description, price, stock, created_at FROM Product")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var products []Product
	for rows.Next() {
		var p Product
		err := rows.Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		products = append(products, p)
	}
	json.NewEncoder(w).Encode(products)
}

func createProductHandler(w http.ResponseWriter, r *http.Request) {
	var newProduct Product
	err := json.NewDecoder(r.Body).Decode(&newProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	err = db.QueryRow(
		"INSERT INTO Product (name, description, price, stock, image_url) VALUES ($1, $2, $3, $4, $5) RETURNING product_id, created_at",
		newProduct.Name, newProduct.Description, newProduct.Price, newProduct.Stock, newProduct.ImageURL,
	).Scan(&newProduct.ProductID, &newProduct.CreatedAt)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(newProduct)
}

func getProductByIDHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	var p Product
	err = db.QueryRow("SELECT product_id, image_url, name, description, price, stock, created_at FROM Product WHERE product_id = $1", id).
		Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt)
	if err == sql.ErrNoRows {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(p)
}

func updateProductHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/update/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	var updatedProduct Product
	err = json.NewDecoder(r.Body).Decode(&updatedProduct)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	updatedProduct.ProductID = id
	err = db.QueryRow(
		"UPDATE Product SET name = $1, description = $2, price = $3, stock = $4, image_url = $5 WHERE product_id = $6 RETURNING created_at",
		updatedProduct.Name, updatedProduct.Description, updatedProduct.Price, updatedProduct.Stock, updatedProduct.ImageURL, id,
	).Scan(&updatedProduct.CreatedAt)
	if err == sql.ErrNoRows {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	json.NewEncoder(w).Encode(updatedProduct)
}

func deleteProductHandler(w http.ResponseWriter, r *http.Request) {
	idStr := strings.TrimPrefix(r.URL.Path, "/products/delete/")
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	result, err := db.Exec("DELETE FROM Product WHERE product_id = $1", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ---------------- PROFILE ------------------

func userProfileHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	var username, email string
	err := db.QueryRow("SELECT username, email FROM users WHERE user_id = $1", userID).Scan(&username, &email)
	if err == sql.ErrNoRows {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	profile := map[string]string{
		"username": username,
		"email":    email,
	}

	json.NewEncoder(w).Encode(profile)
}

func createUserHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var user struct {
		UserID    string `json:"user_id"`
		Email     string `json:"email"`
		Username  string `json:"username"`
		CreatedAt string `json:"created_at"`
	}

	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}
	fmt.Println("Incoming user data:", user)
	_, err := db.Exec(
		`INSERT INTO users (user_id, email, username, created_at)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (user_id)
         DO UPDATE SET email = EXCLUDED.email, username = EXCLUDED.username, created_at = EXCLUDED.created_at`,
		user.UserID, user.Email, user.Username, user.CreatedAt,
	)
	if err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	fmt.Fprint(w, "User created successfully")
}

func updateUserProfileHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	if r.Method != http.MethodPut {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var user struct {
		UserID   string `json:"user_id"`
		Username string `json:"username"`
		Email    string `json:"email"`
	}

	if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
		http.Error(w, "Invalid JSON", http.StatusBadRequest)
		return
	}

	res, err := db.Exec(`UPDATE users SET username = $1, email = $2 WHERE user_id = $3`,
		user.Username, user.Email, user.UserID)
	if err != nil {
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, _ := res.RowsAffected()
	if rowsAffected == 0 {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprint(w, "User updated successfully")
}

// ---------------- FAVORITES ----------------

func favoritesHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	switch {
	case r.URL.Path == "/favorites" && r.Method == http.MethodGet:
		getFavoritesHandler(w, r)
	case r.URL.Path == "/favorites" && r.Method == http.MethodPost:
		addFavoriteHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/favorites/remove/") && r.Method == http.MethodDelete:
		removeFavoriteHandler(w, r)
	default:
		http.Error(w, "Not Found", http.StatusNotFound)
	}
}

func getFavoritesHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(
		`SELECT p.product_id, p.image_url, p.name, p.description, p.price, p.stock, p.created_at
		 FROM Favorites f JOIN Product p ON f.product_id = p.product_id
		 WHERE f.user_id = $1`,
		userID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var favorites []Product
	for rows.Next() {
		var p Product
		if err := rows.Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		favorites = append(favorites, p)
	}
	json.NewEncoder(w).Encode(favorites)
}

func addFavoriteHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	var fav struct {
		ProductID int `json:"product_id"`
	}
	err := json.NewDecoder(r.Body).Decode(&fav)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	_, err = db.Exec(
		"INSERT INTO Favorites (user_id, product_id) VALUES ($1, $2) ON CONFLICT DO NOTHING",
		userID, fav.ProductID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusCreated)
}

func removeFavoriteHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	idStr := strings.TrimPrefix(r.URL.Path, "/favorites/remove/")
	productID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	result, err := db.Exec("DELETE FROM Favorites WHERE user_id = $1 AND product_id = $2", userID, productID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Favorite not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ---------------- CART ----------------

func cartHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")

	if r.Method == http.MethodOptions {
		return
	}

	switch {
	case r.URL.Path == "/cart" && r.Method == http.MethodGet:
		getCartHandler(w, r)
	case r.URL.Path == "/cart" && r.Method == http.MethodPost:
		addToCartHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/cart/update/") && r.Method == http.MethodPut:
		updateCartHandler(w, r)
	case strings.HasPrefix(r.URL.Path, "/cart/remove/") && r.Method == http.MethodDelete:
		removeFromCartHandler(w, r)
	default:
		http.Error(w, "Not Found", http.StatusNotFound)
	}
}

func getCartHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}
	rows, err := db.Query(
		`SELECT p.product_id, p.image_url, p.name, p.description, p.price, p.stock, p.created_at, c.quantity
		 FROM Cart c JOIN Product p ON c.product_id = p.product_id
		 WHERE c.user_id = $1`,
		userID,
	)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type CartItem struct {
		Product  Product `json:"product"`
		Quantity int     `json:"quantity"`
	}
	var cart []CartItem
	for rows.Next() {
		var p Product
		var quantity int
		if err := rows.Scan(&p.ProductID, &p.ImageURL, &p.Name, &p.Description, &p.Price, &p.Stock, &p.CreatedAt, &quantity); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		cart = append(cart, CartItem{Product: p, Quantity: quantity})
	}
	json.NewEncoder(w).Encode(cart)
}

func addToCartHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	var item struct {
		ProductID int `json:"product_id"`
	}
	err := json.NewDecoder(r.Body).Decode(&item)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	var productStock int
	err = db.QueryRow("SELECT stock FROM Product WHERE product_id = $1", item.ProductID).Scan(&productStock)
	if err == sql.ErrNoRows {
		http.Error(w, "Product not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, "DB error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	var existingQuantity int
	err = db.QueryRow("SELECT quantity FROM Cart WHERE user_id = $1 AND product_id = $2", userID, item.ProductID).Scan(&existingQuantity)

	if err == sql.ErrNoRows {
		if productStock < 1 {
			http.Error(w, "Not enough stock", http.StatusBadRequest)
			return
		}
		_, err = db.Exec("INSERT INTO Cart (user_id, product_id, quantity) VALUES ($1, $2, 1)", userID, item.ProductID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	} else if err == nil {
		desiredQty := existingQuantity + 1
		if desiredQty > productStock {
			http.Error(w, "Not enough stock", http.StatusBadRequest)
			return
		}
		_, err = db.Exec("UPDATE Cart SET quantity = $1 WHERE user_id = $2 AND product_id = $3", desiredQty, userID, item.ProductID)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
	} else {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

func updateCartHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	idStr := strings.TrimPrefix(r.URL.Path, "/cart/update/")
	productID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	var item struct {
		Quantity int `json:"quantity"`
	}
	err = json.NewDecoder(r.Body).Decode(&item)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if item.Quantity <= 0 {
		result, err := db.Exec("DELETE FROM Cart WHERE user_id = $1 AND product_id = $2", userID, productID)
		if err != nil {
			http.Error(w, "Error removing from cart: "+err.Error(), http.StatusInternalServerError)
			return
		}
		rowsAffected, _ := result.RowsAffected()
		if rowsAffected == 0 {
			http.Error(w, "Item not found in cart", http.StatusNotFound)
			return
		}
		w.WriteHeader(http.StatusNoContent)
		return
	}

	_, err = db.Exec("UPDATE Cart SET quantity = $1 WHERE user_id = $2 AND product_id = $3", item.Quantity, userID, productID)
	if err != nil {
		http.Error(w, "Error updating cart: "+err.Error(), http.StatusInternalServerError)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}


func removeFromCartHandler(w http.ResponseWriter, r *http.Request) {
	queryValues := r.URL.Query()
	userID := queryValues.Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	idStr := strings.TrimPrefix(r.URL.Path, "/cart/remove/")
	productID, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid Product ID", http.StatusBadRequest)
		return
	}
	result, err := db.Exec("DELETE FROM Cart WHERE user_id = $1 AND product_id = $2", userID, productID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	if rowsAffected == 0 {
		http.Error(w, "Cart item not found", http.StatusNotFound)
		return
	}
	w.WriteHeader(http.StatusNoContent)
}

// ---------------- ORDERS ----------------

func createOrderHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Println(r.URL.Query())
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	if r.Method == http.MethodOptions {
		return
	}
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	// Загружаем все товары пользователя из корзины
	rows, err := db.Query(`
		SELECT p.product_id, p.price, c.quantity
		FROM cart c JOIN product p ON c.product_id = p.product_id
		WHERE c.user_id = $1
	`, userID)
	if err != nil {
		http.Error(w, "Error loading cart: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type CartLine struct {
		ProductID int
		Price     float64
		Quantity  int
	}
	var cartItems []CartLine
	var total float64 = 0

	for rows.Next() {
		var line CartLine
		if err := rows.Scan(&line.ProductID, &line.Price, &line.Quantity); err != nil {
			http.Error(w, "Error scanning cart: "+err.Error(), http.StatusInternalServerError)
			return
		}
		cartItems = append(cartItems, line)
		total += line.Price * float64(line.Quantity)
	}

	if len(cartItems) == 0 {
		http.Error(w, "Cart is empty, cannot create order", http.StatusBadRequest)
		return
	}

	// Создаём заказ
	var orderID int
	err = db.QueryRow(`
		INSERT INTO orders (user_id, total, status)
		VALUES ($1, $2, 'Pending')
		RETURNING order_id
	`, userID, total).Scan(&orderID)
	if err != nil {
		http.Error(w, "Error creating order: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Добавляем товары в order_items
	for _, item := range cartItems {
		_, err := db.Exec(`
			INSERT INTO order_items (order_id, product_id, quantity, price)
			VALUES ($1, $2, $3, $4)
		`, orderID, item.ProductID, item.Quantity, item.Price)
		if err != nil {
			http.Error(w, "Error inserting order items: "+err.Error(), http.StatusInternalServerError)
			return
		}
	}

	// Проверка и обновление стоков
	for _, item := range cartItems {
		var availableStock int
		err := db.QueryRow(`
			SELECT stock FROM product WHERE product_id = $1
		`, item.ProductID).Scan(&availableStock)
		if err != nil {
			http.Error(w, "Error checking stock: "+err.Error(), http.StatusInternalServerError)
			return
		}

		if availableStock < item.Quantity {
			http.Error(w, fmt.Sprintf("Not enough stock for product ID %d. Available: %d, Requested: %d",
				item.ProductID, availableStock, item.Quantity), http.StatusBadRequest)
			return
		}

		_, err = db.Exec(`
			UPDATE product
			SET stock = stock - $1
			WHERE product_id = $2
		`, item.Quantity, item.ProductID)
		if err != nil {
			http.Error(w, "Error updating stock: "+err.Error(), http.StatusInternalServerError)
			return
		}
		fmt.Println("Creating order with total:", total)
		fmt.Println("Adding item to order_items:", item)
		fmt.Println("Updating stock for product:", item.ProductID)
		fmt.Println("Clearing cart for user:", userID)
	}

	// Очищаем корзину
	_, err = db.Exec("DELETE FROM cart WHERE user_id = $1", userID)
	if err != nil {
		http.Error(w, "Error clearing cart: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Возвращаем результат
	type OrderResponse struct {
		OrderID int     `json:"order_id"`
		Total   float64 `json:"total"`
		Status  string  `json:"status"`
	}
	resp := OrderResponse{
		OrderID: orderID,
		Total:   total,
		Status:  "Pending",
	}
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(resp)
}

func getOrdersHandler(w http.ResponseWriter, r *http.Request) {
    fmt.Println("Query Parameters:", r.URL.Query())
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	if r.Method == http.MethodOptions {
		return
	}
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	userID := r.URL.Query().Get("user_id")
	if userID == "" {
		http.Error(w, "user_id is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(`
		SELECT order_id, total, status, created_at
		FROM orders
		WHERE user_id = $1
		ORDER BY created_at DESC
	`, userID)
	if err != nil {
		http.Error(w, "Error loading orders: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	type Order struct {
		OrderID   int     `json:"order_id"`
		Total     float64 `json:"total"`
		Status    string  `json:"status"`
		CreatedAt string  `json:"created_at"`
	}

	var orders []Order
	for rows.Next() {
		var o Order
		if err := rows.Scan(&o.OrderID, &o.Total, &o.Status, &o.CreatedAt); err != nil {
			http.Error(w, "Error scanning orders: "+err.Error(), http.StatusInternalServerError)
			return
		}
		orders = append(orders, o)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(orders)
}

func getOrderItemsHandler(w http.ResponseWriter, r *http.Request) {
	enableCors(&w)
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")

	fmt.Println("Request received at /orders/:order_id/items")

	if r.Method != http.MethodGet {
		fmt.Println("Invalid method:", r.Method)
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	pathParts := strings.Split(r.URL.Path, "/")
	if len(pathParts) < 3 {
		fmt.Println("Invalid path:", r.URL.Path)
		http.Error(w, "Invalid path", http.StatusBadRequest)
		return
	}

	orderIDStr := pathParts[2]
	fmt.Println("Extracted order ID:", orderIDStr)
	orderID, err := strconv.Atoi(orderIDStr)
	if err != nil {
		fmt.Println("Invalid order ID:", orderIDStr)
		http.Error(w, "Invalid order ID", http.StatusBadRequest)
		return
	}

	rows, err := db.Query(`
		SELECT p.product_id, p.name, p.price, oi.quantity
		FROM order_items oi
		JOIN product p ON oi.product_id = p.product_id
		WHERE oi.order_id = $1
	`, orderID)
	if err != nil {
		fmt.Println("DB error:", err)
		http.Error(w, "DB error: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	fmt.Println("DB query successful for order ID:", orderID)

	type OrderItem struct {
		ProductID int     `json:"product_id"`
		Name      string  `json:"name"`
		Price     float64 `json:"price"`
		Quantity  int     `json:"quantity"`
	}
	var items []OrderItem

	for rows.Next() {
		var it OrderItem
		if err := rows.Scan(&it.ProductID, &it.Name, &it.Price, &it.Quantity); err != nil {
			fmt.Println("Scan error:", err)
			http.Error(w, "Scan error: "+err.Error(), http.StatusInternalServerError)
			return
		}
		items = append(items, it)
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(items)
}
