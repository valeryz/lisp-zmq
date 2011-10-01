
(in-package :zeromq-examples)

(defun local-thr (address message-size message-count)
  (zmq:with-context (context 1)
    (zmq:with-socket (socket context :sub)
      (zmq:setsockopt socket :subscribe "")
      (zmq:bind socket address)
      (zmq:with-msg (message)
        (flet ((receive-message ()
                 (zmq:recv socket message)
                 (when (/= (zmq:msg-size message) message-size)
                   (format t "message of incorrect size received~%"))))
          (receive-message)
          (let* ((elapsed-time (zmq:with-stopwatch
                                 (do ((i 0 (1+ i)))
                                     ((= i (- message-count 1)))
                                   (receive-message))))
                 (throughput (* (/ message-count elapsed-time) 1000000))
                 (megabits (/ (* throughput message-size 8) 1000000)))
            (format t "message size: ~A [B]~%" message-size)
            (format t "message count: ~A ~%" message-count)
            (format t "mean throughput ~A [msg/s]~%" (round throughput))
            (format t "mean throughput ~A [Mb/s]~%" (round megabits))))))))
