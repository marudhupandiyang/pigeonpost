// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
//= require dataTables/jquery.dataTables
//= require dataTables/jquery.dataTables.bootstrap

	$(document).ready(function(){

	// $.extend( $.fn.dataTableExt.oStdClasses, {
	// 	"sSortAsc": "header headerSortDown",
	// 	"sSortDesc": "header headerSortUp",
	// 	"sSortable": "header"
	// } );

		//create a jquery datatable for display messages
		// this one is for inbox
		oInboxTable = $('#inbox_table').dataTable({
			  "sDom": "<r>t<pi>",
	  		"sAjaxSource": '/msg/get/inbox' ,
        "bFilter":false,
        "iDisplayLength" : 15,
        "bAutoWidth": false,
        "sPaginationType": "bootstrap",
	  		"bProcessing": false,
    	  "bServerSide": true,
     	  "aoColumns": [{ sWidth: '1%',"bSortable":false },{ sWidth: '19%',"bSortable":true},{ sWidth: '65%',"bSortable":false},{ sWidth: '10%',"bSortable":true }],
		    "fnServerParams": function ( aoData ) {
					if ($.trim($("#search_inbox").val()) != ""){
         		aoData.push( { "name" : "searchq" ,"value" : $("#search_inbox").val() } );
        	}
      	}
		});

		oSentboxTable = $('#sentbox_table').dataTable({
			  "sDom": "<r>t<pi>",
	  		"sAjaxSource": '/msg/get/sentbox' ,
        "bFilter":false,
        "iDisplayLength" : 15,
        "bAutoWidth": false,
        "sPaginationType": "bootstrap",
	  		"bProcessing": false,
    	  "bServerSide": true,
     	  "aoColumns": [{ sWidth: '1%',"bSortable":false },{ sWidth: '19%',"bSortable":true},{ sWidth: '65%',"bSortable":false},{ sWidth: '10%',"bSortable":true }],
		    "fnServerParams": function ( aoData ) {
					if ($.trim($("#search_sentbox").val()) != ""){
         		aoData.push( { "name" : "searchq" ,"value" : $("#search_sentbox").val() } );
        	}
      	}
		});

		oDeleteboxTable = $('#deletebox_table').dataTable({
			  "sDom": "<r>t<pi>",
	  		"sAjaxSource": '/msg/get/deletebox' ,
        "bFilter":false,
        "iDisplayLength" : 15,
        "bAutoWidth": false,
        "sPaginationType": "bootstrap",
	  		"bProcessing": false,
    	  "bServerSide": true,
     	  "aoColumns": [{ sWidth: '1%',"bSortable":false },{ sWidth: '19%',"bSortable":true},{ sWidth: '65%',"bSortable":false},{ sWidth: '10%',"bSortable":true }],
		    "fnServerParams": function ( aoData ) {
					if ($.trim($("#search_deletebox").val()) != ""){
         		aoData.push( { "name" : "searchq" ,"value" : $("#search_deletebox").val() } );
        	}
      	}
		});

		//toggle checkbox in the table when the master check box is changed
		// dn use click function, always use change function (best practice)
	$('.master_check').on("change",function(){
		var tbl=$("#" + $(this).attr("tbl")+ "_table");
		if (this.checked) {
			tbl.find("tbody .msg_check").prop("checked",true);
		}else{
			tbl.find("tbody .msg_check").prop("checked",false);
		}
	});


		// delete selected messages
$('.delete_messsage').click(function(){

	var that = $(this);

	var delete_messages = []; //hold the ids that are to be deleted

	//get all the messages that are checked
	var checked = $("#" + that.attr("tbl") + "_table").find('.msg_check')
	checked.each(function(i){
		if ($(checked[i]).prop('checked')){
			delete_messages.push($(checked[i]).attr('msgid'));
		}
	});


	//if nothing is selected reutnr
	if (delete_messages.length < 1 ){
		alert('Please select atleast one message');
		$("#" + that.attr('tbl') + " .master_check").prop('checked',false);
		return false;
	}

 // delete the messages using ajax
  $.ajax({
		url:'/messages/0',
		data:{msgid:delete_messages , tbl: that.attr('tbl')},
		type:'delete',
		dataType:'json',
		success:function(data){
			// reset the checkbox
			$("#" + that.attr('tbl') + " .master_check").removeAttr('checked');
			if (data['unreadcount'] > 0){
				//$('#unread_count').html("(" + data['unreadcount'] +  ")");
			}
			else{
				//$('#unread_count').html("");
			}
			// redraw the table
			if (that.attr("tbl")=='inbox'){
				oInboxTable.fnDraw();
			}else if (that.attr("tbl")=='sentbox') {
				oSentboxTable.fnDraw();
			}
			else if  (that.attr("tbl")=='deletebox') {
				oDeleteboxTable.fnDraw();
			}
		},
		error:function(){

		}
	});
});

$("#mark_as_read").on("click",function(){

	var that = $(this);

	var checked_messages = []; //hold the ids that are to be deleted

	//get all the messages that are checked
	var checked = $("#inbox_table").find('.msg_check')
	checked.each(function(i){
		if ($(checked[i]).prop('checked')){
			checked_messages.push($(checked[i]).attr('msgid'));
		}
	});


	//if nothing is selected reutnr
	if (checked_messages.length < 1 ){
		alert('Please select atleast one message');
		$("#" + that.attr('tbl') + " .master_check").prop('checked',false);
		return false;
	}

 // delete the messages using ajax
  $.ajax({
		url:'/messages/0',
		data:{msgid:checked_messages},
		type:'put',
		dataType:'json',
		success:function(data){
			// reset the checkbox
			$("#" + that.attr('tbl') + " .master_check").removeAttr('checked');
			if (data['unreadcount'] > 0){
				//$('#unread_count').html("(" + data['unreadcount'] +  ")");
			}
			else{
				//$('#unread_count').html("");
			}
			// redraw the table
			oInboxTable.fnDraw();
		},
		error:function(){

		}
	});
});







		//set css for the clickable column

		$('.message_show_trigger td').on('click',function(){
			if ($(this).index() == 0) return true;

			$(this).closest('tr').children('td:nth-child(4)').children('.showmessage').trigger('click');
		});

		$('.showmessage').on('click', function () {
			var that = $(this);

			showNotifications('Opening message..! Please wait..!');

			$.ajax({
				url: '/street/messages/'	 + that.attr('msgid'),
				type:'get',
				async:false,
				dataType:'json',
				success:function(data){

					var templ = _.template($("#view_msg").html());
					$("#show_msg_content").html(templ({data:data}));

					if (that.parent().parent().hasClass('unread')){
						that.parent().parent().removeClass('unread');
						var count = Number($('#header_msg_count').text().replace("(","").replace(")","")) - 1 ;

							console.log(count + 'count');

						if ( count < 1 ){
							$('#header_msg_count').html('');
							$('#unread_count').html('');
						}
						else{
							$('#header_msg_count').html('('+ count + ')');
							$('#unread_count').html('('+ count + ')');
						}
					}

					$('.back_to_table').attr('tbl',that.closest('table').attr('tbl'));
					//set reply to user and set the msgid to it
					$('.reply_to_user').attr('tbl',that.closest('table').attr('tbl'));
					$('.reply_to_user').attr('msgid',that.attr('msgid'));


					if ($(".back_to_table").attr('tbl') == 'inbox'){
						$("#inbox").hide();
					}else if ($(".back_to_table").attr('tbl') == 'sentbox'){
						$("#sent").hide();
					}
					else if ($(".back_to_table").attr('tbl') == 'deletebox'){
						$("#delete").hide();
					}


					$("#show_msg").show();
				}
				// },
				// error:function(){
				// 	showNotifications("Something went wrong try again");
				// }
			});

			return false;

    	});


		$(".search_messages").keyup(function(){

			if ( $(this).val().length < 3 && $(this).val().length != 0) return false;

			if ($(this).attr('tbl')=='inbox'){
				oInboxTable.fnDraw();
			}
			else if ($(this).attr('tbl')=='sentbox'){
				oSentboxTable.fnDraw();
			}
			else if ($(this).attr('tbl')=='deletebox'){
				oDeleteboxTable.fnDraw();
			}

		});

		$('.back_to_table').click(function(){
			$("#show_msg").hide();
			if ($(this).attr('tbl') == 'inbox'){
				$("#inbox").css({"display":"block"});
			}else if ($(this).attr('tbl') == 'sentbox'){
				$("#sent").css({"display":""});
			}
			else if ($(this).attr('tbl') == 'deletebox'){
				$("#delete").css({"display":""});
			}
		});

		$('#reply_to_button').on('click',function(){

			$("#reply_to_modal .reply_to_user #p2p_message_receiver_id").val($("#show_msg .message_user_name").attr('recevid'));

			if ($.trim($(".message_user_name_content").text()) == 'Admin'){
				$("#reply_to_user").html("Sociorent" );
			}
			else{
				$("#reply_to_user").html($.trim($(".message_user_name_content").text()) );

			}


			$("#reply_to_modal .reply_to_user #p2p_message_parent_id").val($(".reply_to_user").attr('msgid'));
			console.log($("#reply_to_modal"));
			//$("#message_user_name").attr("recev")
		});


		$(".refresh_messsage").click(function(){
			if ($(this).attr('tbl') == 'inbox'){
				oInboxTable.fnDraw();
			}
			else if ($(this).attr('tbl') == 'sentbox'){
				oSentboxTable.fnDraw();
			}
			else if ($(this).attr('tbl') == 'deletebox'){
				oDeleteboxTable.fnDraw();
			}
		});

	});
