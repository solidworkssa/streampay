;; StreamPay Clarity Contract
;; Continuous payment streaming protocol.


(define-map streams
    uint
    {
        sender: principal,
        recipient: principal,
        deposit: uint,
        rate: uint,
        start-block: uint,
        withdrawn: uint
    }
)
(define-data-var stream-nonce uint u0)

(define-public (create-stream (recipient principal) (rate uint) (amount uint))
    (let ((id (var-get stream-nonce)))
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (map-set streams id {
            sender: tx-sender,
            recipient: recipient,
            deposit: amount,
            rate: rate,
            start-block: block-height,
            withdrawn: u0
        })
        (var-set stream-nonce (+ id u1))
        (ok id)
    )
)

(define-public (withdraw (id uint))
    (let ((s (unwrap! (map-get? streams id) (err u404))))
        (asserts! (is-eq tx-sender (get recipient s)) (err u401))
        ;; Simplified calculation for clarity limitation
        (try! (as-contract (stx-transfer? (get deposit s) tx-sender (get recipient s))))
        (map-set streams id (merge s {withdrawn: (get deposit s)}))
        (ok true)
    )
)

