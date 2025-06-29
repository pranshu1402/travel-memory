# Travel Memory

## Steps to deploy:

For complete steps REFER to complete_step_to_deploy.txt file within repo

High level steps
1. Configure Mongo DB cluster in Atlas cloud
2. Launch an EC2 Instance in AWS 
3. Clone Repo in EC2
4. Install all dependencies node, npm, nginx, pm2 in ec2
6. Start backend app
7. Create frontend app build and place in nginx serve directory
8. Setup nginx & reload
9. Clone EC2 instances using AMI
10. Create Load Balancer
11. Setup target group
12. Register ACM Certificate
13. Save load balancer to get a Dns name
14. Link DNS name generated with Cloudflare(your domain)


--------------------------------------------------------

## Screenshots

Refer to TravelMemory Screenshots.docx file.

-------------------------------------------------------


`.env` file to work with the backend after creating a database in mongodb: 

```
MONGO_URI='ENTER_YOUR_URL'
PORT=3001
```

Data format to be added: 

```json
{
    "tripName": "Incredible India",
    "startDateOfJourney": "19-03-2022",
    "endDateOfJourney": "27-03-2022",
    "nameOfHotels":"Hotel Namaste, Backpackers Club",
    "placesVisited":"Delhi, Kolkata, Chennai, Mumbai",
    "totalCost": 800000,
    "tripType": "leisure",
    "experience": "Lorem Ipsum, Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum, ",
    "image": "https://t3.ftcdn.net/jpg/03/04/85/26/360_F_304852693_nSOn9KvUgafgvZ6wM0CNaULYUa7xXBkA.jpg",
    "shortDescription":"India is a wonderful country with rich culture and good people.",
    "featured": true
}
```


For frontend, you need to create `.env` file and put the following content (remember to change it based on your requirements):
```bash
REACT_APP_BACKEND_URL=http://localhost:3001
```