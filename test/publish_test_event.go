package main

import (
	"bytes"
	"context"
	"fmt"
	"log"
	"time"

	"cloud.google.com/go/pubsub"
)

// encodeVarint encodes an int64 as a protobuf varint
func encodeVarint(v int64) []byte {
	var buf bytes.Buffer
	for v >= 0x80 {
		buf.WriteByte(byte(v&0x7f) | 0x80)
		v >>= 7
	}
	buf.WriteByte(byte(v))
	return buf.Bytes()
}

// encodeString encodes a string field with tag
func encodeString(fieldNum int, s string) []byte {
	var buf bytes.Buffer
	// Tag: field number << 3 | wire type 2 (length-delimited)
	tag := (fieldNum << 3) | 2
	buf.Write(encodeVarint(int64(tag)))
	buf.Write(encodeVarint(int64(len(s))))
	buf.WriteString(s)
	return buf.Bytes()
}

// encodeInt64 encodes an int64 field with tag
func encodeInt64(fieldNum int, v int64) []byte {
	var buf bytes.Buffer
	// Tag: field number << 3 | wire type 0 (varint)
	tag := (fieldNum << 3) | 0
	buf.Write(encodeVarint(int64(tag)))
	buf.Write(encodeVarint(v))
	return buf.Bytes()
}

// encodeTestEvent encodes a TestEvent as protobuf binary
// message TestEvent {
//   string id = 1;
//   string message = 2;
//   int64 timestamp = 3;
// }
func encodeTestEvent(id, message string, timestamp int64) []byte {
	var buf bytes.Buffer
	buf.Write(encodeString(1, id))
	buf.Write(encodeString(2, message))
	buf.Write(encodeInt64(3, timestamp))
	return buf.Bytes()
}

func main() {
	ctx := context.Background()
	projectID := "experimental-sandbox-445216"
	topicID := "Test_Event"

	// Create Pub/Sub client
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	topic := client.Topic(topicID)

	// Create test event data
	id := "test-002"
	message := "Hello from Go protobuf test!"
	// BigQuery TIMESTAMP expects microseconds, not seconds
	timestamp := time.Now().UnixMicro()

	// Encode as protobuf binary
	data := encodeTestEvent(id, message, timestamp)

	fmt.Printf("Encoded protobuf (%d bytes): %x\n", len(data), data)

	// Publish message
	result := topic.Publish(ctx, &pubsub.Message{
		Data: data,
	})

	// Wait for publish to complete
	msgID, err := result.Get(ctx)
	if err != nil {
		log.Fatalf("Failed to publish: %v", err)
	}

	fmt.Printf("Published message ID: %s\n", msgID)
	fmt.Printf("Event: id=%s, message=%s, timestamp=%d\n", id, message, timestamp)
}
