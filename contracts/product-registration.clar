;; Product Registration Contract
;; Records merchandise details and manages product information

(define-data-var admin principal tx-sender)

;; Product status: 0 = active, 1 = discontinued
(define-map products
  { product-id: (string-ascii 32) }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    category: (string-utf8 50),
    manufacturer: (string-utf8 100),
    status: uint,
    created-by: principal,
    created-at: uint
  }
)

;; Register a new product
(define-public (register-product
    (product-id (string-ascii 32))
    (name (string-utf8 100))
    (description (string-utf8 500))
    (category (string-utf8 50))
    (manufacturer (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? products { product-id: product-id })) (err u409))
    (map-set products
      { product-id: product-id }
      {
        name: name,
        description: description,
        category: category,
        manufacturer: manufacturer,
        status: u0,
        created-by: tx-sender,
        created-at: block-height
      }
    )
    (ok true)
  )
)

;; Update product details
(define-public (update-product
    (product-id (string-ascii 32))
    (name (string-utf8 100))
    (description (string-utf8 500))
    (category (string-utf8 50))
    (manufacturer (string-utf8 100)))
  (let ((product (unwrap! (map-get? products { product-id: product-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set products
      { product-id: product-id }
      (merge product {
        name: name,
        description: description,
        category: category,
        manufacturer: manufacturer
      })
    )
    (ok true)
  )
)

;; Discontinue a product
(define-public (discontinue-product (product-id (string-ascii 32)))
  (let ((product (unwrap! (map-get? products { product-id: product-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (map-set products
      { product-id: product-id }
      (merge product { status: u1 })
    )
    (ok true)
  )
)

;; Get product details
(define-read-only (get-product (product-id (string-ascii 32)))
  (map-get? products { product-id: product-id })
)

;; Check if product exists and is active
(define-read-only (is-product-active (product-id (string-ascii 32)))
  (match (map-get? products { product-id: product-id })
    product (is-eq (get status product) u0)
    false
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
