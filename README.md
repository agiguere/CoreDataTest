# CoreData Persiting History Limitation

This sample application has a CoreData model with 1 entity named Post.

When the app start, nothing is created yet in the database. From the main menu, you can click on Create Entity to create the first entity.

We only need to create 1 entity to show the limitation of the persisting history, if you click more than 1 time on 'Create Entity', the same entity will be created but with a different ID.

Click on Fetch Entities to display the list of entities, they should only be 1 post.

Click on the tableview cell to navigate to the detail view controller.

Click on Edit
Type something in the comment TextField and hit return.
Click Done to save the context and create your first transaction.

Repeat the above steps another time to create another transaction.

Go back to the menu
Click on fetch history, you should see 3 changes in the transaction history.
Transaction 1 = the initial creation
Transaction 2 = your first change
Transaction 3 = your second change

if you click on the table view cell for any transaction, nothing will happens on the UI but in code I am printing the changes in the console. Please check the code for detail ...

There is no way to know what was the comment value at the time of Transaction 2

we only know Transaction 2 change the comment field and that's it

not very usefull if you building a sync mechanism to push all changes to your own backend.

thanks
