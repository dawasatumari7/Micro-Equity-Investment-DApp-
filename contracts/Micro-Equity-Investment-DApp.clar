(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-PROJECT-EXISTS (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))
(define-constant ERR-PROJECT-NOT-FOUND (err u103))
(define-constant ERR-INSUFFICIENT-TOKENS (err u104))

(define-data-var total-projects uint u0)

(define-map projects 
    { project-id: uint }
    {
        owner: principal,
        name: (string-ascii 64),
        total-shares: uint,
        available-shares: uint,
        price-per-share: uint,
        total-profits: uint
    }
)

(define-map investor-shares
    { project-id: uint, investor: principal }
    { shares: uint }
)

(define-public (create-project (name (string-ascii 64)) (total-shares uint) (price-per-share uint))
    (let ((project-id (var-get total-projects)))
        (asserts! (> total-shares u0) ERR-INVALID-AMOUNT)
        (asserts! (> price-per-share u0) ERR-INVALID-AMOUNT)
        
        (map-insert projects 
            { project-id: project-id }
            {
                owner: tx-sender,
                name: name,
                total-shares: total-shares,
                available-shares: total-shares,
                price-per-share: price-per-share,
                total-profits: u0
            }
        )
        
        (var-set total-projects (+ project-id u1))
        (ok project-id)
    )
)

(define-public (invest (project-id uint) (shares uint))
    (let (
        (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
        (total-cost (* shares (get price-per-share project)))
    )
        (asserts! (<= shares (get available-shares project)) ERR-INSUFFICIENT-TOKENS)
        (asserts! (>= shares u0) ERR-INVALID-AMOUNT)
        
        (try! (stx-transfer? total-cost tx-sender (get owner project)))
        
        (map-set projects
            { project-id: project-id }
            (merge project {
                available-shares: (- (get available-shares project) shares)
            })
        )
        
        (map-set investor-shares
            { project-id: project-id, investor: tx-sender }
            { shares: (default-to u0 (get shares (map-get? investor-shares { project-id: project-id, investor: tx-sender }))) }
        )
        
        (ok true)
    )
)

(define-public (distribute-profits (project-id uint) (profit uint))
    (let ((project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get owner project)) ERR-NOT-AUTHORIZED)
        
        (map-set projects
            { project-id: project-id }
            (merge project {
                total-profits: (+ (get total-profits project) profit)
            })
        )
        
        (ok true)
    )
)

(define-read-only (get-project (project-id uint))
    (ok (map-get? projects { project-id: project-id }))
)

(define-read-only (get-investor-shares (project-id uint) (investor principal))
    (ok (map-get? investor-shares { project-id: project-id, investor: investor }))
)

(define-public (transfer-shares (project-id uint) (recipient principal) (shares uint))
    (let (
        (sender-shares (unwrap! (map-get? investor-shares { project-id: project-id, investor: tx-sender }) ERR-PROJECT-NOT-FOUND))
        (project (unwrap! (map-get? projects { project-id: project-id }) ERR-PROJECT-NOT-FOUND))
    )
        (asserts! (>= (get shares sender-shares) shares) ERR-INSUFFICIENT-TOKENS)
        
        (map-set investor-shares
            { project-id: project-id, investor: tx-sender }
            { shares: (- (get shares sender-shares) shares) }
        )
        
        (map-set investor-shares
            { project-id: project-id, investor: recipient }
            { shares: (+ shares (default-to u0 (get shares (map-get? investor-shares { project-id: project-id, investor: recipient })))) }
        )
        
        (ok true)
    )
)
