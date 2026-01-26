;; StreamPay - Continuous payment streaming

(define-data-var stream-counter uint u0)

(define-map streams uint {
    sender: principal,
    receiver: principal,
    amount: uint,
    start-block: uint,
    duration: uint,
    withdrawn: uint,
    active: bool
})

(define-constant ERR-UNAUTHORIZED (err u101))

(define-public (create-stream (receiver principal) (duration uint))
    (let ((stream-id (var-get stream-counter)))
        (try! (stx-transfer? tx-sender (as-contract tx-sender) tx-sender))
        (map-set streams stream-id {
            sender: tx-sender,
            receiver: receiver,
            amount: u0,
            start-block: block-height,
            duration: duration,
            withdrawn: u0,
            active: true
        })
        (var-set stream-counter (+ stream-id u1))
        (ok stream-id)))

(define-public (withdraw-stream (stream-id uint))
    (let ((stream (unwrap! (map-get? streams stream-id) ERR-UNAUTHORIZED)))
        (asserts! (is-eq (get receiver stream) tx-sender) ERR-UNAUTHORIZED)
        (ok true)))

(define-read-only (get-stream (stream-id uint))
    (ok (map-get? streams stream-id)))
