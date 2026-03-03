package com.mantra.mantra.audio

import android.util.Log
import java.io.ByteArrayOutputStream
import java.io.DataOutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Accumulates raw PCM audio frames into a buffer and can export them
 * as a WAV byte array for sending to Sarvam.ai REST API.
 *
 * Thread-safe — frames are written from the audio thread, WAV is
 * read from the main thread.
 */
class AudioBufferManager {

    companion object {
        private const val TAG = "AudioBufferManager"
        private const val SAMPLE_RATE = 16000
        private const val CHANNELS = 1
        private const val BITS_PER_SAMPLE = 16

        /** Maximum buffer size: ~30 seconds of 16kHz mono PCM = 960KB */
        private const val MAX_BUFFER_BYTES = SAMPLE_RATE * 2 * 30
    }

    private val lock = Any()
    private var buffer = ByteArrayOutputStream()
    private var isBuffering = false

    /** Start accumulating audio frames. */
    fun startBuffering() {
        synchronized(lock) {
            buffer.reset()
            isBuffering = true
            Log.i(TAG, "Buffering started")
        }
    }

    /** Add a frame of PCM samples to the buffer. */
    fun addFrame(samples: ShortArray) {
        synchronized(lock) {
            if (!isBuffering) return
            if (buffer.size() >= MAX_BUFFER_BYTES) return // prevent OOM

            val bytes = ByteBuffer.allocate(samples.size * 2)
                .order(ByteOrder.LITTLE_ENDIAN)
            for (s in samples) {
                bytes.putShort(s)
            }
            buffer.write(bytes.array())
        }
    }

    /**
     * Flush the buffer and return its contents as a WAV byte array.
     * Returns null if buffer is empty. Resets the buffer after flushing.
     */
    fun flushAsWav(): ByteArray? {
        synchronized(lock) {
            val pcmData = buffer.toByteArray()
            buffer.reset()

            if (pcmData.isEmpty()) return null

            Log.i(TAG, "Flushing buffer: ${pcmData.size} bytes (${pcmData.size / (SAMPLE_RATE * 2.0)}s)")
            return pcmToWav(pcmData)
        }
    }

    /** Stop buffering and discard accumulated data. */
    fun stopBuffering() {
        synchronized(lock) {
            isBuffering = false
            buffer.reset()
            Log.i(TAG, "Buffering stopped")
        }
    }

    /** Current buffer duration in milliseconds. */
    fun bufferDurationMs(): Long {
        synchronized(lock) {
            return (buffer.size().toLong() * 1000) / (SAMPLE_RATE * 2)
        }
    }

    /** Whether we're actively buffering. */
    fun isActive(): Boolean = synchronized(lock) { isBuffering }

    /**
     * Convert raw PCM bytes to a WAV file byte array.
     * WAV format: 44-byte header + raw PCM data.
     */
    private fun pcmToWav(pcmData: ByteArray): ByteArray {
        val totalDataLen = pcmData.size + 36
        val byteRate = SAMPLE_RATE * CHANNELS * BITS_PER_SAMPLE / 8
        val blockAlign = CHANNELS * BITS_PER_SAMPLE / 8

        val out = ByteArrayOutputStream()
        val dos = DataOutputStream(out)

        // RIFF header
        dos.writeBytes("RIFF")
        dos.writeIntLE(totalDataLen)
        dos.writeBytes("WAVE")

        // fmt chunk
        dos.writeBytes("fmt ")
        dos.writeIntLE(16) // chunk size
        dos.writeShortLE(1) // PCM format
        dos.writeShortLE(CHANNELS)
        dos.writeIntLE(SAMPLE_RATE)
        dos.writeIntLE(byteRate)
        dos.writeShortLE(blockAlign)
        dos.writeShortLE(BITS_PER_SAMPLE)

        // data chunk
        dos.writeBytes("data")
        dos.writeIntLE(pcmData.size)
        dos.write(pcmData)

        dos.flush()
        return out.toByteArray()
    }

    /** Write a 32-bit integer in little-endian. */
    private fun DataOutputStream.writeIntLE(value: Int) {
        write(value and 0xFF)
        write((value shr 8) and 0xFF)
        write((value shr 16) and 0xFF)
        write((value shr 24) and 0xFF)
    }

    /** Write a 16-bit short in little-endian. */
    private fun DataOutputStream.writeShortLE(value: Int) {
        write(value and 0xFF)
        write((value shr 8) and 0xFF)
    }
}
