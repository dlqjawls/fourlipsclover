package com.patriot.fourlipsclover.settlement.dto.request;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateParticipantRequest {

	private List<Long> memberId;
}
