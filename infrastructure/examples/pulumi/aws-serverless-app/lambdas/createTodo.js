const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');
const dynamodb = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
  const tableName = process.env.TABLE_NAME;
  
  try {
    const requestBody = JSON.parse(event.body);
    
    if (!requestBody.title) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ message: 'Title is required' })
      };
    }
    
    const todo = {
      id: uuidv4(),
      title: requestBody.title,
      completed: false,
      createdAt: new Date().toISOString()
    };
    
    const params = {
      TableName: tableName,
      Item: todo
    };
    
    await dynamodb.put(params).promise();
    
    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(todo)
    };
  } catch (error) {
    console.error('Error creating todo:', error);
    
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ message: 'Error creating todo' })
    };
  }
};
